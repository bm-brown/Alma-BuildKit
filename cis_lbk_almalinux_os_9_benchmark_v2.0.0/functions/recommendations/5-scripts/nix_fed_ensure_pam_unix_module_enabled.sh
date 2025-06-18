#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = fd5be9ce
#   function = fed_ensure_pam_unix_module_enabled
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_pam_unix_module_enabled.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar       10/17/23    Recommendation "Ensure pam_unix module is enabled"
#

fed_ensure_pam_unix_module_enabled()
{
    # Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure pam_unix module is enabled \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

    fed_ensure_pam_unix_module_enabled_chk()
    {
        echo -e "- Start check - Ensure pam_unix module is enabled" | tee -a "$LOG" 2>> "$ELOG"
        l_output=""

        #  Verify that pam_unix is enabled
        l_output="$(grep -P -- '\bpam_unix.so\b' /etc/pam.d/{password,system}-auth)"

        if [ -n "$l_output" ]; then
            echo -e "- PASS: pam_unix module is enabled" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_unix module is enabled" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else 
            echo -e "- FAIL: pam_unix module is NOT enabled" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_unix module is enabled" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"    
        fi 
    }

    fed_ensure_pam_unix_module_enabled_fix()
    {
        echo -e "- Start remediation - Ensure pam_unix module is enabled" | tee -a "$LOG" 2>> "$ELOG"
        l_module_name="unix"
        l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"

        #  verify the pam_unix.so lines exist in the profile templates
        if grep -Pq -- '^custom\/' <<< "$l_pam_profile"; then
            l_pam_profile_path="/etc/authselect/$l_pam_profile"
        else
            l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
        fi
        grep -P -- "\bpam_$l_module_name\.so\b" "$l_pam_profile_path"/{password,system}-auth
        
        echo -e "- Manual remediation is required - review the changes to ensure the authselect profile meets site policy" | tee -a "$LOG" 2>> "$ELOG"
        l_test="manual"
                
        echo -e "- End remediation - Ensure pam_unix module is enabled" | tee -a "$LOG" 2>> "$ELOG"

    }

    fed_ensure_pam_unix_module_enabled_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_pam_unix_module_enabled_fix
        if [ "$l_test" != "manual" ]; then
            fed_ensure_pam_unix_module_enabled_chk
            if [ "$?" = "101" ]; then
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
