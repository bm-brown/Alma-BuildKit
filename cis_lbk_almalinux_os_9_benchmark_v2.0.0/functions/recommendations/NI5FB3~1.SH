#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = a3720598
#   function = fed_ensure_password_quality_enforced_for_root_user
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_password_quality_enforced_for_root_user.sh
# 
# Name                Date          Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar        08/29/23      Recommendation "Ensure password quality is enforced for the root user"
#

fed_ensure_password_quality_enforced_for_root_user()
{
    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    fed_ensure_password_quality_enforced_for_root_user_chk()
    {
          echo -e "- Start check - Ensure password quality is enforced for the root user" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        if grep -Pqi '^\h*enforce_for_root\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf 2>/dev/null; then
            l_output="$l_output\n- Entry found in pwquality.conf: enforce_for_root"
        else
            l_output2="$l_output2 \n- NO Entry found in pwquality.conf for enforce_for_root"
        fi

        if [ -z "$l_output2" ]; then
            echo -e "- PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password quality is enforced for the root user" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "- FAIL:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password quality is enforced for the root user" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi
    }

    fed_ensure_password_quality_enforced_for_root_user_fix()
    {
       echo -e "- Start remediation - Ensure password quality is enforced for the root" | tee -a "$LOG" 2>> "$ELOG"
        
        if ! grep -Pqi '^\h*enforce_for_root\b' /etc/security/pwquality.conf; then
            echo -e "enforce_for_root" >> /etc/security/pwquality.conf
            echo -e "- Added enforce_for_root entry to /etc/security/pwquality.conf" | tee -a "$LOG" 2>> "$ELOG"
        else
            echo -e "- Entry already exists in /etc/security/pwquality.conf, no action needed" | tee -a "$LOG" 2>> "$ELOG"
        fi
        
        echo -e "- End remediation - Ensure password quality is enforced for the root" | tee -a "$LOG" 2>> "$ELOG"
    }

   fed_ensure_password_quality_enforced_for_root_user_chk
    if [ "$?" = "101" ]; then
            [ -z "$l_test" ] && l_test="passed"
        else
            if [ "$l_test" != "NA" ]; then
                fed_ensure_password_quality_enforced_for_root_user_fix
                fed_ensure_password_quality_enforced_for_root_user_chk
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
