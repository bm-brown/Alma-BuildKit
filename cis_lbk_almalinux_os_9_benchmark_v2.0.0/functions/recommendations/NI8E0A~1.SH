#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = d3fbd95c
#   function = fed_ensure_pam_unix_includes_use_authtok
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_pam_unix_includes_use_authtok.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar        10/19/26   Recommendation "Ensure pam_unix includes use_authtok"
#

fed_ensure_pam_unix_includes_use_authtok()
{
    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure pam_unix includes use_authtok \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    fed_ensure_pam_unix_includes_use_authtok_chk()
    {
        echo -e "- Start check - Ensure pam_unix includes use_authtok" | tee -a "$LOG" 2>> "$ELOG"

        # verify that use_authtok is set on the pam_unix.so module lines in the password stack
        if grep -P -- '^\h*password\h+([^#\n\r]+)\h+pam_unix\.so\h+([^#\n\r]+\h+)?use_authtok\b' /etc/pam.d/{password,system}-auth; then
            echo -e "- PASS: pam_unix includes use_authtok" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_unix includes use_authtok" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "- PASS: pam_unix does NOT include use_authtok" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_unix includes use_authtok" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi    
    }

    fed_ensure_pam_unix_includes_use_authtok_fix()
    {
        echo -e "- Start remediation - Ensure pam_unix includes use_authtok" | tee -a "$LOG" 2>> "$ELOG"
        l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"

        # update template to include use_authtok
        if grep -Pq -- '^custom\/' <<< "$l_pam_profile"; then
            l_pam_profile_path="/etc/authselect/$l_pam_profile"
        else
            l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
        fi

        for l_authselect_file in "$l_pam_profile_path"/password-auth "$l_pam_profile_path"/system-auth; do
            if  grep -Pq '^\h*password\h+([^#\n\r]+)\h+pam_unix\.so\h+([^#\n\r]+\h+)?use_authtok\b' "$l_authselect_file"; then
                echo "- \"use_authtok\" is already set"
            else
                echo "- \"use_authtok\" is not set. Updating template"
                sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_unix\.so\s+.*)$/& use_authtok/g' "$l_authselect_file"
            fi
        done

        # update the password-auth and system-auth files in /etc/pam.d to include the use_authtok argument on the password stack's pam_unix.so lines
        authselect apply-changes

        echo -e "- End remediation - Ensure pam_unix includes use_authtok" | tee -a "$LOG" 2>> "$ELOG"

    }

    fed_ensure_pam_unix_includes_use_authtok_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_pam_unix_includes_use_authtok_fix
        if [ "$l_test" != "manual" ]; then
        fed_ensure_pam_unix_includes_use_authtok_chk
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