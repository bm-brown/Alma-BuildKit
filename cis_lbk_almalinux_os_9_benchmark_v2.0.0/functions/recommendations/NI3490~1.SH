#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 6009b4bb
#   function = fed_ensure_password_unlock_time_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_password_unlock_time_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar       10/18/23    Recommendation "Ensure password unlock time is configured"
#

fed_ensure_password_unlock_time_configured()
{
    # Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure password unlock time is configured \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

    fed_ensure_password_unlock_time_configured_chk()
    {
        echo -e "- Start check - Ensure password unlock time is configured" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""
        
        #  verify that the time in seconds before the account is unlocked is either 0 (never) or 900
        if grep -Pi -- '^\h*unlock_time\h*=\h*(0|9[0-9][0-9]|[1-9][0-9]{3,})\b' /etc/security/faillock.conf; then
            if grep -Pi -- '^\h*auth\h+(requisite|required|sufficient)\h+pam_faillock\.so\h+([^#\n\r]+\h+)?unlock_time\h*=\h*([1-9]|[1-9][0-9]|[1-8][0-9][0-9])\b' /etc/pam.d/system-auth /etc/pam.d/password-auth; then
                l_output2="$l_output2\n -  password failed attempts is NOT configured /etc/pam.d/system-auth /etc/pam.d/password-auth"
            else
                l_output="$l_output\n - password failed attemmpts lockout is correctly configured"    
            fi 
        else
            l_output2="$l_output2\n - password failed attempts is NOT configured in /etc/security/faillock.conf"
        fi

        if [ -z "$l_output2" ]; then
            echo -e "-PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password unlock time is configured"
            return "${XCCDF_RESULT_PASS:-101}" 
        else
            echo -e "FAIL:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password unlock time is configured"
            return "${XCCDF_RESULT_FAIL:-102}" 
        fi                
    }

    fed_ensure_password_unlock_time_configured_fix()
    {
        echo -e "- Start remediation - Ensure password unlock time configured" | tee -a "$LOG" 2>> "$ELOG"
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"
        
        # Setting the unlock_time option to 900 in /etc/security/faillock.conf
        sed -i '/^\s*#*\s*unlock_time\s*=/ s/.*/unlock_time = 900/' /etc/security/faillock.conf
           
        #  remove the unlock_time argument from the pam_faillock.so module in the PAM files
        for l_pam_file in system-auth password-auth; do
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"
        sed -ri 's/(^\s*auth\s+(requisite|required|sufficient)\s+pam_faillock\.so.*)(\s+unlock_time\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
        done

        authselect apply-changes

        echo -e "- End remediation - Ensure password unlock time is configured" | tee -a "$LOG" 2>> "$ELOG"
            
    }  

    fed_ensure_password_unlock_time_configured_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_password_unlock_time_configured_fix
        fed_ensure_password_unlock_time_configured_chk
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
