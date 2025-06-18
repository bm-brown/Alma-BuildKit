#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = b05c0cf8
#   function = fed_ensure_active_authselect_profile_includes_pam_modules
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_active_authselect_profile_includes_pam_modules.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar       10/17/23    Recommendation "Ensure active authselect profile includes pam modules"
#

fed_ensure_active_authselect_profile_includes_pam_modules()
{
    # Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation  Ensure active authselect profile includes pam modules \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

    fed_ensure_active_authselect_profile_includes_pam_modules_chk()
    {
        echo -e "- Start check - Ensure active authselect profile includes pam modules" | tee -a "$LOG" 2>> "$ELOG"
        l_pwquality="" l_pwhistory="" l_faillock="" l_unix=""

        l_pwquality="$(grep -P -- '\b(pam_pwquality\.so)\b' /etc/authselect/"$(head -1 /etc/authselect/authselect.conf)"/{system,password}-auth)"
        l_pwhistory="$(grep -P -- '\b(pam_pwhistory\.so)\b' /etc/authselect/"$(head -1 /etc/authselect/authselect.conf)"/{system,password}-auth)"
        l_faillock="$(grep -P -- '\b(pam_faillock\.so)\b' /etc/authselect/"$(head -1 /etc/authselect/authselect.conf)"/{system,password}-auth)"
        l_unix="$(grep -P -- '\b(pam_unix\.so)\b' /etc/authselect/"$(head -1 /etc/authselect/authselect.conf)"/{system,password}-auth)"

        # verify the active authselect profile includes lines for the pwquality, pwhistory, faillock, and unix modules
        if [ -n "$l_pwquality" ] && [ -n "$l_pwhistory" ] && [ -n "$l_faillock" ] && [ -n "$l_unix" ]; then
            echo -e "- PASS:\n- active authselect profile includes pam modules" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- Found Entries:\n$l_pwquality\n\n$l_pwhistory\n\n$l_faillock\n\n$l_unix" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure active authselect profile includes pam modules" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "- FAIL:\n active authselect profile DOES NOT include pam modules" | tee -a "$LOG" 2>> "$ELOG"
            [ -z "$l_pwquality" ] && echo -e "- pam_pwquality /etc/authselect/ DOES NOT include pam modules" | tee -a "$LOG" 2>> "$ELOG"
            [ -z "$l_pwhistory" ] && echo -e "- pam_pwhistory /etc/authselect/ DOES NOT include pam modules" | tee -a "$LOG" 2>> "$ELOG"
            [ -z "$l_faillock" ] && echo -e "- pam_faillock /etc/authselect/ DOES NOT include pam modules" | tee -a "$LOG" 2>> "$ELOG"
            [ -z "$l_unix" ] && echo -e "- pam_unix /etc/authselect/ DOES NOT include pam modules" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure active authselect profile includes pam modules" | tee -a "$LOG" 2>> "$ELOG"
            return"${XCCDF_RESULT_FAIL:-102}"
        fi     
           
    }

    fed_ensure_active_authselect_profile_includes_pam_modules_fix()
    {
        echo -e "- Start remediation - Ensure active authselect profile includes pam modules" | tee -a "$LOG" 2>> "$ELOG"

        # run the following command to create a custom authselect profile
        authselect create-profile CIS-custom-profile -b sssd

        # run the following command to select a custom authselect profile
        authselect select custom/CIS-custom-profile --backup=PAM_CONFIG_BACKUP

        echo -e "- Manual remediation is required - review the changes to ensure the authselect profile meets site policy" | tee -a "$LOG" 2>> "$ELOG"
        l_test="manual"

        echo -e "- End remediation - Ensure active authselect profile includes pam modules" | tee -a "$LOG" 2>> "$ELOG"

    }

    fed_ensure_active_authselect_profile_includes_pam_modules_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_active_authselect_profile_includes_pam_modules_fix
        if [ "$l_test" != "manual" ]; then
            fed_ensure_active_authselect_profile_includes_pam_modules_chk
            if  [ "$?" = "101" ]; then
                [ "$l_test" != "failed" ] && l_test="remediated"
            else
                l_test="failed"
           fi
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