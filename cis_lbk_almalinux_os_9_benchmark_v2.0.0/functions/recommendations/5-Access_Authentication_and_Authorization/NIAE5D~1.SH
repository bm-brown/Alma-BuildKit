#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = c9c68b02
#   function = fed_ensure_pam_pwhistory_includes_use_authtok
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_pam_pwhistory_includes_use_authtok.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar        10/18/23   Recommendation "Ensure pam_pwhistory includes use_authtok"
#

fed_ensure_pam_pwhistory_includes_use_authtok()
{
    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure pam_pwhistory includes use_authtok \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    fed_ensure_pam_pwhistory_includes_use_authtok_chk()
    {
       echo -e "- Start check - Ensure pam_pwhistory includes use_authtok" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" passwd_auth="" system_auth=""

        if grep -P -- '^\h*password\h+([^#\n\r]+)\h+pam_pwhistory\.so\h+([^#\n\r]+\h+)?use_authtok\b' /etc/pam.d/password-auth; then
            echo -e "- pam_pwhistory includes use_authtok in /etc/pam.d/password-auth" | tee -a "$LOG" 2>> "$ELOG"
            passwd_auth="passed"
        else
            l_output+="pam_pwhistory does NOT include use_authtok in /etc/pam.d/password-auth"
            passwd_auth="failed"
        fi

        if grep -P -- '^\h*password\h+([^#\n\r]+)\h+pam_pwhistory\.so\h+([^#\n\r]+\h+)?use_authtok\b' /etc/pam.d/system-auth; then
            echo -e "- pam_pwhistory includes use_authtok in /etc/pam.d/system-auth" | tee -a "$LOG" 2>> "$ELOG"
            system_auth="passed"
        else
            l_output+="pam_pwhistory does NOT include use_authtok in /etc/pam.d/system-auth"
            system_auth="failed"
        fi

        if [ "$passwd_auth" = "passed" ] && [ "$system_auth" = "passed" ]; then
            echo -e "-PASS: 'use_authtok' setting found on pam_pwhistory.so module lines" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_pwhistory includes use_authtok"
        return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "FAIL: $l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_pwhistory includes use_authtok"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi
    }

    fed_ensure_pam_pwhistory_includes_use_authtok_fix()
    {
        echo -e "- Start remediation - Ensure pam_pwhistory includes use_authtok" | tee -a "$LOG" 2>> "$ELOG"

        for file in "/etc/pam.d/password-auth" "/etc/pam.d/system-auth"; do
            if ! grep -Piq -- '^\h*password\h+([^#\n\r]+)\h+pam_pwhistory\.so\h+([^#\n\r]+\h+)?use_authtok\b' $file; then
                if grep -Piq -- '^\h*password\h+([^#\n\r]+)\h+pam_pwhistory\.so\h+' $file; then
                    echo -e "- Adding 'enforce_for_root' to $file" | tee -a "$LOG" 2>> "$ELOG"
                    sed -ri 's/(^\s*password\s+([^#\n\r]+)\s+pam_pwhistory\.so\s+.*)/\1 use_authtok/g' $file
                else
                    echo -e "- Adding password required pam_pwhistory.so 'enforce_for_root' to $file" | tee -a "$LOG" 2>> "$ELOG"
                    sed -ri '/password\s+sufficient\s+pam_unix\.so/i password    required      pam_pwhistory.so remember=24 enforce_for_root try_first_pass use_authtok' $file
                fi
            fi
        done
    }

    echo -e "- End remediation - Ensure pam_pwhistory includes use_authtok" | tee -a "$LOG" 2>> "$ELOG"


    fed_ensure_pam_pwhistory_includes_use_authtok_chk
    if [ "$?" = "101" ]; then
        [ -z "$l_test" ] && l_test="passed"
    else
        fed_ensure_pam_pwhistory_includes_use_authtok_fix
        if [ "$l_test" != "manual" ]; then
            fed_ensure_pam_pwhistory_includes_use_authtok_chk
         if [ "$?" = "101" ] ; then
                [ "$l_test" != "failed" ] && l_test="remediated"
            else
                l_test="failed"
            fi
        fi
    fi

	# Set return code and return
	case "$l_test" in
		passed)
			echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
			;;
		remediated)
			echo "Recommendation \"$RNA\" successfully remediated" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-103}"
			;;
		manual)
			echo "Recommendation \"$RNA\" requires manual remediation" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-106}"
			;;
		NA)
			echo "Recommendation \"$RNA\" Something went wrong - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}