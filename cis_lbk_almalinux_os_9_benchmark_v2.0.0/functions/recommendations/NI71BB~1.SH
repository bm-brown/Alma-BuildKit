#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = a688b202
#   function = fed_ensure_password_failed_attempts_lockout_includes_root
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_password_failed_attempts_lockout_includes_root.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar       10/18/23    Recommendation "Ensure password failed attempts lockout includes root account"
#

fed_ensure_password_failed_attempts_lockout_includes_root()
{
    # Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure password failed attempts lockout includes root account \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

    fed_ensure_password_failed_attempts_lockout_includes_root_chk()
    {
        echo -e "- Start check - Ensure password failed attempts lockout includes root account" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        # Check for even_deny_root
        if grep -qPi -- '^\h*even_deny_root\b' /etc/security/faillock.conf; then
            l_output="$l_output\n - even_deny_root is correctly set in /etc/security/faillock.conf"

            # Check root_unlock_time value
            root_unlock_time=$(grep -Pi -- '^\h*root_unlock_time\h*=\h*(\d+)' /etc/security/faillock.conf | grep -Po '\d+')
            if [ -z "$root_unlock_time" ]; then
                l_output="$l_output\n - root_unlock_time is not set in /etc/security/faillock.conf"
            elif ((root_unlock_time >= 60)); then
                l_output="$l_output\n - root_unlock_time is 60 or more in /etc/security/faillock.conf"
            else
                l_output2="$l_output2\n - root_unlock_time is not 60 or more in /etc/security/faillock.conf"
            fi
        else
            l_output2="$l_output2\n - even_deny_root is NOT set in /etc/security/faillock.conf"
        fi

        if [ -z "$l_output2" ]; then
            echo -e "- PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password failed attempts lockout includes root account"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "FAIL:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password failed attempts lockout includes root account"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi
        
    }

    fed_ensure_password_failed_attempts_lockout_includes_root_fix()
    {
        echo -e "- Start remediation -Ensure password failed attempts lockout includes root account" | tee -a "$LOG" 2>> "$ELOG"

        # Edit /etc/security/faillock.conf
        if ! grep -qPi -- '^\s*even_deny_root\b' /etc/security/faillock.conf; then
            echo 'even_deny_root' >> /etc/security/faillock.conf  # Add even_deny_root if not present
        fi

        # Update root_unlock_time to 60 if it's less than 60
        if grep -qPi -- '^\s*root_unlock_time\s*=\s*([0-9]|[1-5][0-9])\b' /etc/security/faillock.conf; then
            sed -i -r -e 's/^\s*root_unlock_time\s*=\s*([0-9]|[1-5][0-9])\b/root_unlock_time = 60/' /etc/security/faillock.conf
        fi

        for l_pam_file in system-auth password-auth; do
            l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"
            sed -ri 's/(^\s*auth\s+(.*)\s+pam_faillock\.so.*)(\s+even_deny_root)(.*$)/\1\4/' "$l_authselect_file"
            sed -ri 's/(^\s*auth\s+(.*)\s+pam_faillock\.so.*)(\s+root_unlock_time\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
        done

        authselect apply-changes

        echo -e "- End remediation - Ensure password failed attempts lockout includes root account" | tee -a "$LOG" 2>> "$ELOG"
        
    }

    fed_ensure_password_failed_attempts_lockout_includes_root_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_password_failed_attempts_lockout_includes_root_fix
        fed_ensure_password_failed_attempts_lockout_includes_root_chk
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
