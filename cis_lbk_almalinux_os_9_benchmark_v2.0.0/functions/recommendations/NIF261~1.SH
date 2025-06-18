#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 09f0ee7d
#   function = fed_ensure_password_failed_attempts_lockout_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_password_failed_attempts_lockout_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar       10/18/23    Recommendation "Ensure password failed attempts lockout is configured"
#

fed_ensure_password_failed_attempts_lockout_configured()
{
    # Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure password failed attempts lockout is configured \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

    fed_ensure_password_failed_attempts_lockout_configured_chk()
    {
        echo -e "- Start check - Ensure password failed attempts lockout is configured" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""
        
        # verify that Number of failed logon attempts before the account is locked is no greater than 5, and the deny argument has not been set, or 5 or less and meets local site policy
        if grep -Pi -- '^\h*deny\h*=\h*[1-5]\b' /etc/security/faillock.conf; then
            if grep -Pi -- '^\h*auth\h+(requisite|required|sufficient)\h+pam_faillock\.so\h+([^#\n\r]+\h+)?deny\h*=\h*(0|[6-9]|[1-9][0-9]+)\b' /etc/pam.d/system-auth /etc/pam.d/password-auth; then
                l_output2="$l_output2\n - password failed attempts is incorrectly configured in /etc/pam.d/system-auth /etc/pam.d/password-auth"
            else
                l_output="$l_output\n - password failed attemmpts lockout is correctly configured"
            fi
        else
            l_output2="$l_output2\n - password failed attempts is incorrectly configured in /etc/security/faillock.conf"        
        fi

        if [ -z "$l_output2" ]; then
            echo -e "-PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password failed attempts lockout is configured"
            return "${XCCDF_RESULT_PASS:-101}" 
        else
            echo -e "FAIL:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password failed attempts lockout is configured"
            return "${XCCDF_RESULT_FAIL:-102}" 
        fi                
    }

    fed_ensure_password_failed_attempts_lockout_configured_fix()
    {
        echo -e "- Start remediation - Ensure password failed attempts lockout configured" | tee -a "$LOG" 2>> "$ELOG"
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"

        # Setting the deny option to 5 in /etc/security/faillock.conf
        if grep -Pi -- '^\h*deny\h*=\h*([1-5])\b' /etc/security/faillock.conf; then
            sed -ri '/^\s*#*\s*deny\s*=/ {s/^\s*#*\s*deny\s*=\s*[0-9]+\b/deny = 5/;b}; /^\s*#*\s*deny\s*=/! {s/^\s*#*\s*deny\s*=.*/deny = 5/;b}; /^\s*#*\s*deny\s*=/ {s/^\s*#*\s*deny\s*=\s*[6-9].*/deny = 5/}' /etc/security/faillock.conf
        else
            # If deny is not set, add it as deny = 5
            echo "deny = 5" >> /etc/security/faillock.conf
        fi
        
        #  remove the deny argument from the pam_faillock.so module in the PAM files
        for l_pam_file in system-auth password-auth; do
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"
        sed -ri 's/(^\s*auth\s+(requisite|required|sufficient)\s+pam_faillock\.so.*)(\s+deny\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
        done

        authselect apply-changes

        echo -e "- End remediation - Ensure password failed attempts lockout is configured" | tee -a "$LOG" 2>> "$ELOG"
            
    }  

    fed_ensure_password_failed_attempts_lockout_configured_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_password_failed_attempts_lockout_configured_fix
        fed_ensure_password_failed_attempts_lockout_configured_chk
        if [ "$?" = "101" ]; then
			[ "$l_test" != "failed" ] && l_test="remediated"
		fi
	fi

    # Set return code, end recommendation entry in verbose log, and return
	case "$l_test" in
		passed)
			echo -e "- Result - No remediation required\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
			;;
		remediated)
			echo -e "- Result - successfully remediated\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-103}"
			;;
		manual)
			echo -e "- Result - requires manual remediation\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-106}"
			;;
		NA)
			echo -e "- Result - Recommendation is non applicable\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo -e "- Result - remediation failed\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
	    ;;
	esac
          
}