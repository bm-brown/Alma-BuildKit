#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 4122ee50
#   function = fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar        10/19/26   Recommendation "Ensure pam_unix includes a strong password hashing algorithm"
#

fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm()
{

    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - includes a strong password hashing algorithm \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm_chk()
    {
        echo -e "- Start check - Ensure pam_unix includes a strong password hashing algorithm" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        #  verify that a strong password hashing algorithm is set on the pam_unix.so module
        if grep -P -- '^\h*password\h+([^#\n\r]+)\h+pam_unix\.so\h+([^#\n\r]+\h+)?(sha512|yescrypt)\b' /etc/pam.d/password-auth; then
            if grep -P -- '^\h*password\h+([^#\n\r]+)\h+pam_unix\.so\h+([^#\n\r]+\h+)?(sha512|yescrypt)\b' /etc/pam.d/system-auth; then
                l_output="$l_output\n - password hashing algorithm is correctly set to use either sha512 or yescrypt"
            else
                l_output2="$l_output2\n - password hashing algorithm is NOT correctly set in /etc/pam.d/system-auth"
            fi
        else
            l_output2="$l_output2\n - password hashing algorithim is NOT correctly set in /etc/pam.d/password-auth"
        fi

        if [ -z "$l_output2" ]; then
            echo -e "- PASS: password hashing algorithm is correctly set to use either sha512 or yescrypt" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_unix includes a strong password hashing algorithm" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else    
            echo -e "- FAIL: password hashing algorithim is NOT correctly set in \n$l_output2\n" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_unix includes a strong password hashing algorithm" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi                  

    }

    fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm_fix()
    {
        echo -e " Start remediation - Ensure pam_unix includes a strong password hashing algorithm" | tee -a "$LOG" 2>> "$ELOG"
        l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"

        # Updating password hashing algorithm on the password stack's pam_unix.so module lines
        l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"
        if grep -Pq -- '^custom\/' <<< "$l_pam_profile"; then
            l_pam_profile_path="/etc/authselect/$l_pam_profile"
        else
            l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
        fi

        for l_authselect_file in "$l_pam_profile_path"/password-auth "$l_pam_profile_path"/system-auth; do
            if  grep -Pq '^\h*password\h+()\h+pam_unix\.so\h+([^#\n\r]+\h+)?(md5|bigcrypt|sha256|blowfish)\b' "$l_authselect_file"; then
                echo "- A weak password hashing algorithm is set, updating to \"sha512\""
                sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_unix\.so\s+.*)(md5|bigcrypt|sha256|blowfish)(\s*.*)$/\1\4 sha512/g' "$l_authselect_file"
            else
                echo "No password hashing algorithm is set, updating to \"sha512\""
                sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_unix\.so\s+.*)$/& sha512/g' "$l_authselect_file"
            fi
        done

        # Run the following command to update the password-auth and system-auth files in /etc/pam.d to include pam_unix.so with a strong password hashing algorithm argument
        authselect apply-changes

        echo -e "- End remediation - Ensure pam_unix includes a strong password hashing algorithm" | tee -a "$LOG" 2>> "$ELOG"
    }

    fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm_fix
        if [ "$l_test" != "manual" ]; then
            fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm_chk
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