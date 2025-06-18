#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 2b8409e5
#   function = fed_ensure_pam_unix_does_not_include_remember
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_pam_unix_does_not_include_remember.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar        10/18/23   Recommendation "Ensure pam_unix does not include remember"
# 

fed_ensure_pam_unix_does_not_include_remember()
{
    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure pam_unix does not include remember \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    fed_ensure_pam_unix_does_not_include_remember_chk()
    {
        echo -e "- Start check - Ensure pam_unix does not include remember" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        #  verify that the remember argument is not set on the pam_unix.so module
        if grep -Pi '^\h*password\h+([^#\n\r]+\h+)?pam_unix\.so\b' /etc/pam.d/password-auth | grep -Pv '\bremember=\d\b'; then
            if grep -Pi '^\h*password\h+([^#\n\r]+\h+)?pam_unix\.so\b' /etc/pam.d/system-auth | grep -Pv '\bremember=\d\b'; then
                l_output="$l_output\n - pam_unix is correctly configured the remember argument is not set"
            else
                l_output2="$l_output2\n - remember argument is set in /etc/pam.d/system-auth"
            fi 
        else
            l_output2="$l_output2\n - remember argument is set in /etc/pam.d/password-auth"    
        fi

        if [ -z "$l_output2" ]; then
            echo -e "- PASS: pam_unix is correctly configured the remember argument is not set" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check Ensure pam_unix does not include remember" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else    
            echo -e "- FAIL: pam_unix includes remember \n$l_output2\n" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check Ensure pam_unix does not include remember" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi    
    }
    fed_ensure_pam_unix_does_not_include_remember_fix()
    {
        echo -e "- Start remediation - Ensure pam_unix does not include remember" | tee -a "$LOG" 2>> "$ELOG"
        l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"

        # remove the remember= from the pam_unix.so lines in the active authselect profile password-auth and system-auth templates
        if grep -Pq -- '^custom\/' <<< "$l_pam_profile"; then
            l_pam_profile_path="/etc/authselect/$l_pam_profile"
        else
            l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
        fi
        for l_authselect_file in "$l_pam_profile_path"/password-auth "$l_pam_profile_path"/system-auth; do
            sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_unix\.so\s+.*)(remember=[1-9][0-9]*)(\s*.*)$/\1\4/g' "$l_authselect_file"
        done

        # Run the following command to update the password-auth and system-authfiles in/etc/pam.d to include pam_unix.so without the remember argumen
        authselect apply-changes

        echo -e "- End rememdiation - Ensure pam_unix does not include remember" | tee -a "$LOG" 2>> "$ELOG"
    }

    fed_ensure_pam_unix_does_not_include_remember_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_pam_unix_does_not_include_remember_fix
        if [ "$l_test" != "manual" ]; then
            fed_ensure_pam_unix_does_not_include_remember_chk
        if [ "$?" = "101" ]; then
                [ "$l_test" != "failed" ] && l_test="remediated"
                
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