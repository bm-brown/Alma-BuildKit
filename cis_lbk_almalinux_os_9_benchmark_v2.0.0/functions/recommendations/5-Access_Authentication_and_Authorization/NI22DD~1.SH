#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = b40a75a0
#   function = fed_ensure_password_history_remember_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_password_history_remember_configured.sh
# 
# Name                Date          Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar        11/03/23      Recommendation "Ensure password history remember is configured"
#

fed_ensure_password_history_remember_configured()
{
    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure password history remember is configured \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    fed_ensure_password_history_remember_configured_chk()
    {
        echo -e "- Start check - Ensure password history remember is configured" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        if grep -Pi -- '^\h*remember\h*=\h*24\b' /etc/security/pwhistory.conf; then
            if ! grep -Pin -- '^\h*password\h+(requisite|required|sufficient)\h+pam_pwhistory\.so\h+([^#\n\r]+\h+)?remember=' /etc/pam.d/system-auth /etc/pam.d/password-auth; then
                l_output="$l_output\n - password history remember is correctly configured"
            else
                l_output2="$l_output2\n - password history remember is incorrectly configured in /etc/pam.d/system-auth /etc/pam.d/password-auth"
            fi		
        else
            l_output2="$l_output2\n - password history is NOT configured correctly in /etc/security/pwhistory.conf"
        fi

        if [ -z "$l_output2" ]; then
            echo -e "- PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password history remember is configured" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "- FAIL:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password history remember is configured" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi 

    }

    fed_ensure_password_history_remember_configured_fix()
    {
        echo -e "- Start remediation - Ensure password history remember is configured" | tee -a "$LOG" 2>> "$ELOG"

        # Set remember=24 in /etc/security/pwhistory.conf if not set or less than 24
        # Set remember=24 in /etc/security/pwhistory.conf if not set or less than 24
        if grep -qPi '^\s*#\s*remember\s*=\s*10' /etc/security/pwhistory.conf; then
            sed -i -E 's/^\s*#\s*remember\s*=\s*10/remember = 24/' /etc/security/pwhistory.conf
            echo "- Updated remember password history to 24 in /etc/security/pwhistory.conf"
        elif grep -qPi '^\s*remember\s*=\s*(2[0-3]|[01]?[0-9])?\b' /etc/security/pwhistory.conf; then
            sed -i -E 's/^\s*remember\s*=\s*(2[0-3]|[01]?[0-9])?\b/remember = 24/' /etc/security/pwhistory.conf
            echo "- Updated remember password history to 24 in /etc/security/pwhistory.conf"
        elif grep -qPi '^\s*#\s*remember\b' /etc/security/pwhistory.conf; then
            sed -i -E 's/^\s*#\s*remember\b/remember = 24/' /etc/security/pwhistory.conf
            echo "- Updated remember password history to 24 in /etc/security/pwhistory.conf"
        else
            echo "remember = 24" >> /etc/security/pwhistory.conf
            echo "- Added remember password history set to 24 in /etc/security/pwhistory.conf"
        fi

        # Remove the remember argument from the pam_pwhistory.so module in /etc/pam.d/system-auth and /etc/pam.d/password-auth
        for l_pam_file in system-auth password-auth; do
            l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"
            if [ -f "$l_authselect_file" ]; then
                sed -i -E 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwhistory\.so.*)(\s+remember\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
                echo "- Removed 'remember' argument from $l_authselect_file"
                authselect apply-changes
            else
                echo "Manual remediation is required - $l_authselect_file not found"
                l_test="manual"
            fi
        done

        echo -e "- End remediation - Ensure password history remember is configured" | tee -a "$LOG" 2>> "$ELOG"
    }

    fed_ensure_password_history_remember_configured_chk
    if [ "$?" = "101" ]; then
        [ -z "$l_test" ] && l_test="passed"
    else
        fed_ensure_password_history_remember_configured_fix
        fed_ensure_password_history_remember_configured_chk
        if [ "$?" = "101" ]; then
            [ "$l_test" != "failed" ] && l_test="remediated"
        else
            l_test="failed"
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