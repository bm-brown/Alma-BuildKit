#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 280a80a1
#   function = ensure_prevent_dictionary_words_in_password_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_prevent_dictionary_words_in_password_configured.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Justin Brown       07/02/23    Recommendation "Ensure preventing the use of dictionary words for passwords is configured"
#

ensure_prevent_dictionary_words_in_password_configured()
{
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    ensure_prevent_dictionary_words_in_password_configured_chk()
	{
        echo -e "- Start check - Ensure preventing the use of dictionary words for passwords is configured" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        if grep -Piq '^\h*dictcheck\h*=\h*[^0](\h*#.*$)?$' /etc/security/pwquality.conf; then
            l_output="$l_output\n- Entry found in pwquality.conf: $(grep -Pi '^\h*dictcheck\h*=\h*' /etc/security/pwquality.conf)"
        elif grep -Piq '^\h*#\h*dictcheck\h*=\h*' /etc/security/pwquality.conf; then
            l_output2="$l_output2\n- Commented entry found in pwquality.conf: $(grep -Pi '^\h*#\h*dictcheck\h*=\h*' /etc/security/pwquality.conf)"
        elif grep -Piq '^\h*dictcheck\h*=\h*' /etc/security/pwquality.conf; then
            l_output2="$l_output2\n- Incorrect entry found in pwquality.conf: $(grep -Pi '^\h*dictcheck\h*=\h*' /etc/security/pwquality.conf)"
        else
            l_output2="$l_output2\n- NO Entry found in pwquality.conf for dictcheck"
        fi

        if [ -z "$l_output2" ]; then
            echo -e "- PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure preventing the use of dictionary words for passwords is configured" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "- FAIL:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure preventing the use of dictionary words for passwords is configured" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi
    }

    ensure_prevent_dictionary_words_in_password_configured_fix()
	{
        echo -e "- Start remediation - Ensure preventing the use of dictionary words for passwords is configured" | tee -a "$LOG" 2>> "$ELOG"

        if grep -Piq '^\h*(#\h*)?dictcheck\s+' /etc/security/pwquality.conf; then
            echo -e "- Updating dictcheck entry in /etc/security/pwquality.conf" | tee -a "$LOG" 2>> "$ELOG"
            sed -ri 's/^\s*(#\s*)?(dictcheck\s*=)(\s*\S+\s*)(\s+#.*)?$/\2 1\4/' /etc/security/pwquality.conf
        else
            echo -e "- Adding dictcheck entry to /etc/security/pwquality.conf" | tee -a "$LOG" 2>> "$ELOG"
            echo "dictcheck = 1" >> /etc/security/pwquality.conf
        fi

        echo -e "- End remediation - Ensure preventing the use of dictionary words for passwords is configured" | tee -a "$LOG" 2>> "$ELOG"
    }

    ensure_prevent_dictionary_words_in_password_configured_chk
    if [ "$?" = "101" ]; then
        [ -z "$l_test" ] && l_test="passed"
    else
        if [ "$l_test" != "NA" ]; then
            ensure_prevent_dictionary_words_in_password_configured_fix
            ensure_prevent_dictionary_words_in_password_configured_chk
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