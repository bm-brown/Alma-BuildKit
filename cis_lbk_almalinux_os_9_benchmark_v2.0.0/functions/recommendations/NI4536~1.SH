#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = c785ac95
#   function = fed_ensure_password_length_configured
#   applicable =
# # END METADATA
#
#
#
#
#
#
#
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_password_length_configured.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Gokhan Lus          07/02/24    Recommendation "Ensure password length is configured"
#

fed_ensure_password_length_configured()
{
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""
   
    fed_ensure_password_length_configured_chk()
	{
        echo -e "- Start check - Ensure password length is configured" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        # Check password length
        if grep -Piq '^\s*minlen\s*=\s*(1[4-9]|[2-9][0-9]|[1-9][0-9]{2,})\b' /etc/security/pwquality.conf; then
            l_output="$l_output\n- Correct password length setting found in /etc/security/pwquality.conf: $(grep -Pi '^\s*minlen\s*=\s*(1[4-9]|[2-9][0-9]|[1-9][0-9]{2,})\b' /etc/security/pwquality.conf)"
        elif grep -Piq '^\s*(#\s*)?minlen\s*=' /etc/security/pwquality.conf; then
            l_output2="$l_output2\n- Incorrect password length setting found in /etc/security/pwquality.conf: $(grep -Pi '^\s*(#\s*)?minlen\s*=' /etc/security/pwquality.conf)"
        else
            l_output2="$l_output2\n- No minlen setting found in /etc/security/pwquality.conf"
        fi
      
        if [ -z "$l_output2" ]; then
            echo -e "- PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password length is configured" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "- FAIL:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure password length is configured" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi
    }

    fed_ensure_password_length_configured_fix()
	{
        echo -e "- Start remediation - Ensure password length is configured" | tee -a "$LOG" 2>> "$ELOG"
        
        if ! grep -Piq '^\s*minlen\s*=\s*(1[4-9]|[2-9][0-9]|[1-9][0-9][0-9]+)\b' /etc/security/pwquality.conf; then
            if grep -Piq '^\s*(#\s*)?minlen\s*=' /etc/security/pwquality.conf; then
               echo -e "- Updating minlen entry in /etc/security/pwquality.conf" | tee -a "$LOG" 2>> "$ELOG"
               sed -ri 's/^\s*(#\s*)?(minlen\s*=)(\s*\S+\s*)(\s+#.*)?$/\2 14\4/' /etc/security/pwquality.conf
            else
               echo -e "- Adding minlen entry to /etc/security/pwquality.conf" | tee -a "$LOG" 2>> "$ELOG"
               echo "minlen = 14" >> /etc/security/pwquality.conf
            fi
        fi
        
        echo -e "- End remediation - Ensure password length is configured" | tee -a "$LOG" 2>> "$ELOG"
    }

    fed_ensure_password_length_configured_chk
    if [ $? -eq 101 ]; then
        [ -z "$l_test" ] && l_test="passed"
    else
        if [ "$l_test" != "NA" ]; then
            fed_ensure_password_length_configured_fix
            if [ "$l_test" != "manual" ]; then
                fed_ensure_password_length_configured_chk
               if [ "$?" = "101" ]; then
                [ "$l_test" != "failed" ] && l_test="remediated"
               else
                l_test="failed"
               fi 
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