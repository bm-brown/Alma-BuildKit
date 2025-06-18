#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 19461218
#   function = fed_ensure_pam_faillock_module_enabled
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_pam_faillock_module_enabled.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar       10/17/23    Recommendation "Ensure pam_faillock module is enabled"
#

fed_ensure_pam_faillock_module_enabled()
{
    # Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure pam_faillock module is enabled \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

    fed_ensure_pam_faillock_module_enabled_chk()
    {
        echo -e "- Start check - Ensure pam_faillock module is enabled" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        # Verify pam_faillock in password-auth
        if grep -P -- '.*pam_faillock\.so.*' /etc/pam.d/password-auth; then
            # verify pam_faillock in system-auth
            if grep -P -- '.*pam_faillock\.so.*' /etc/pam.d/system-auth; then
                l_output="$l_output\n - pam_faillock module is correctly set"
            else
                l_output2="$l_output2\n - pam_faillock module is not set in /etc/pam.d/system-auth"
            fi
        else
            l_output2="$l_output2\n - pam_faillock module is not set in /etc/pam.d/password-auth"
        fi

        if [ -z "$l_output2" ]; then
            echo -e "- PASS: pam_faillock module is enabled" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_faillock module is enabled" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else 
            echo -e "- FAIL: pam_faillock module is NOT enabled$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_faillock module is enabled" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"    
        fi
    }

    fed_ensure_pam_faillock_module_enabled_fix()
    {
        echo -e "- Start remediation - Ensure pam_faillock module is enabled" | tee -a "$LOG" 2>> "$ELOG"
        l_module_name="faillock"
        
        # Check if the authselect configuration file exists
        if [ -f /etc/authselect/authselect.conf ]; then
            l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"

            # Verify and process the PAM profile
            if grep -Pq -- '^custom\/' <<< "$l_pam_profile"; then
                l_pam_profile_path="/etc/authselect/$l_pam_profile"
            else
                l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
            fi

            # Check if the PAM profile files exist and then run grep commands
            if [ -f "$l_pam_profile_path/password-auth" ] && [ -f "$l_pam_profile_path/system-auth" ]; then
                grep -P -- "\bpam_$l_module_name\.so\b" "$l_pam_profile_path"/{password,system}-auth
                # Perform the rest of the remediation steps here (authselect commands)
                authselect enable-feature with-faillock
                authselect apply-changes
                echo -e "- End of remediation - pam_faillock module is enabled" | tee -a "$LOG" 2>> "$ELOG"
            else
                # Files are missing; manual remediation required
                echo -e "- Manual remediation is required: Refer to Recommendation 4.4.2.1 - Ensure active authselect profile includes pam modules" | tee -a "$LOG" 2>> "$ELOG"
                l_test="manual"
            fi
        else
            # Authselect configuration file missing; manual remediation required
            echo -e "- Manual remediation is required: Refer to Recommendation 4.4.2.1 - Ensure active authselect profile includes pam modules" | tee -a "$LOG" 2>> "$ELOG"
            l_test="manual"
        fi
           
        echo -e "- End remediation - Ensure pam_faillock module is enabled" | tee -a "$LOG" 2>> "$ELOG"
    }

    fed_ensure_pam_faillock_module_enabled_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_pam_faillock_module_enabled_fix
        if [ "$l_test" != "manual" ]; then
            fed_ensure_pam_faillock_module_enabled_chk
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
