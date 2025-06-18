#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = b6bfda4c
#   function = ensure_nologin_not_listed_etc_shells
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_nologin_not_listed_etc_shells.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Justin Brown       07/03/23    Recommendation "Ensure nologin is not listed in /etc/shells"
#

ensure_nologin_not_listed_etc_shells()
{
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    ensure_nologin_not_listed_etc_shells_chk()
	{
        echo -e "- Start check - Ensure nologin is not listed in /etc/shells" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        if grep -Piq '^\h*.*/nologin\b' /etc/shells; then
            l_output2="$l_output2\n- Entry found in /etc/shells: $(grep -Pi '^\h*.*/nologin\b' /etc/shells)"
        else
            l_output="$l_output\n- NO Entry found in /etc/shells for nologin"
        fi

        if [ -z "$l_output2" ]; then
            echo -e "- PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure nologin is not listed in /etc/shells" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "- FAIL:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure nologin is not listed in /etc/shells" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi
    }

    ensure_nologin_not_listed_etc_shells_fix()
	{
        echo -e "- Start remediation - Ensure nologin is not listed in /etc/shells" | tee -a "$LOG" 2>> "$ELOG"

        if grep -Piq '^\h*.*/nologin\b' /etc/shells; then
            echo -e "- Updating nologin entry in /etc/shells" | tee -a "$LOG" 2>> "$ELOG"
            sed -ri 's|(^\s*.*/nologin\b.*$)||g' /etc/shells
        fi

        echo -e "- End remediation - Ensure nologin is not listed in /etc/shells" | tee -a "$LOG" 2>> "$ELOG"
    }

    ensure_nologin_not_listed_etc_shells_chk
    if [ "$?" = "101" ]; then
        [ -z "$l_test" ] && l_test="passed"
    else
        if [ "$l_test" != "NA" ]; then
            ensure_nologin_not_listed_etc_shells_fix
            ensure_nologin_not_listed_etc_shells_chk
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