#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = bc8818d1
#   function = fed_ensure_password_complexity_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_password_complexity_configured.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/05/20    Recommendation "Ensure password complexity is configured "
# Justin Brown       05/14/22    Updated to modern format
# Randie Bejar       10/18/23    Updated to match changes in BM

fed_ensure_password_complexity_configured()
{
   echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure password complexity is configured \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
   test=""

   fed_ensure_password_complexity_configured_chk()
   {
      echo -e "- Start check - Ensure password complexity is configured " | tee -a "$LOG" 2>> "$ELOG"
      l_output="" l_test1="" l_test2=""

      # Check password complexity
      if grep -Eqs '^\s*minclass\s*=\s*4\b' /etc/security/pwquality.conf; then
         l_output="$l_output\n- Correct minclass setting found in /etc/security/pwquality.conf: $(grep -Es '^\s*minclass\s*=\s*4\b' /etc/security/pwquality.conf)"
         l_test1=passed
      elif grep -Eqs '^\s*(#\s*)?minclass\s*=' /etc/security/pwquality.conf; then
         l_output="$l_output\n- Incorrect minclass setting found in /etc/security/pwquality.conf: $(grep -Es '^\s*(#\s*)?minclass\s*=' /etc/security/pwquality.conf)"
      else
         l_output="$l_output\n- No minclass setting found in /etc/security/pwquality.conf"
      fi

      if [ -z "$l_test1" ]; then
         if grep -Eqs '^\s*dcredit\s*=\s*-[1-9]\b' /etc/security/pwquality.conf && grep -Eqs '^\s*ucredit\s*=\s*-[1-9]\b' /etc/security/pwquality.conf && grep -Eqs '^\s*ocredit\s*=\s*-[1-9]\b' /etc/security/pwquality.conf && grep -Eqs '^\s*lcredit\s*=\s*-[1-9]\b' /etc/security/pwquality.conf; then
            l_output="$l_output\n- Correct dcredit, ucredit, ocredit and lcredit settings found in /etc/security/pwquality.conf:\n$( grep -Es '^\s*[duol]credit\s*=' /etc/security/pwquality.conf)"
            l_test2=passed
         elif grep -Eqs '^\s*(#\s*)?dcredit\s*=' /etc/security/pwquality.conf || grep -Eqs '^\s*(#\s*)?ucredit\s*=' /etc/security/pwquality.conf && grep -Eqs '^\s*(#\s*)?ocredit\s*=' /etc/security/pwquality.conf || grep -Eqs '^\s*(#\s*)?lcredit\s*=' /etc/security/pwquality.conf; then
            l_output="$l_output\n- Incorrect dcredit, ucredit, ocredit and lcredit settings found in /etc/security/pwquality.conf:\n$( grep -Es '^\s*(#\s*)?[duol]credit\s*=' /etc/security/pwquality.conf)"
         else
            l_output="$l_output\n- No dcredit, ucredit, ocredit or lcredit settings found in /etc/security/pwquality.conf"
         fi
      fi

      if [ "$l_test1" = "passed" ] || [ "$l_test2" = "passed" ]; then
         echo -e "- PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
         echo -e "- End check - Ensure password complexity is configured" | tee -a "$LOG" 2>> "$ELOG"
         return "${XCCDF_RESULT_PASS:-101}"
      else
         echo -e "- FAIL:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
         echo -e "- End check - Ensure password complexity is configured" | tee -a "$LOG" 2>> "$ELOG"
         return "${XCCDF_RESULT_FAIL:-102}"
      fi

      echo -e "- End check - Ensure password complexity is configured" | tee -a "$LOG" 2>> "$ELOG"

    }

   fed_ensure_password_complexity_configured_fix()
   {
      echo -e "- Start remediation - Ensure password complexity is configured " | tee -a "$LOG" 2>> "$ELOG"

      if ! grep -Eqs '^\s*dcredit\s*=\s*-[1-9]\b' /etc/security/pwquality.conf && ! grep -Eqs '^\s*ucredit\s*=\s*-[1-9]\b' /etc/security/pwquality.conf && ! grep -Eqs '^\s*ocredit\s*=\s*-[1-9]\b' /etc/security/pwquality.conf && ! grep -Eqs '^\s*lcredit\s*=\s*-[1-9]\b' /etc/security/pwquality.conf; then
         if grep -Eqs '^\s*[duol]credit\s*=' /etc/security/pwquality.conf; then
            echo -e "- Commenting out any dcredit, ucredit, ocredit and lcredit entries in /etc/security/pwquality.conf" | tee -a "$LOG" 2>> "$ELOG"
            grep -Eqs '^\s*dcredit\s*=' /etc/security/pwquality.conf && sed -i 's/^\s*dcredit\s*=/# &/' /etc/security/pwquality.conf
            grep -Eqs '^\s*ucredit\s*=' /etc/security/pwquality.conf && sed -i 's/^\s*ucredit\s*=/# &/' /etc/security/pwquality.conf
            grep -Eqs '^\s*ocredit\s*=' /etc/security/pwquality.conf && sed -i 's/^\s*ocredit\s*=/# &/' /etc/security/pwquality.conf
            grep -Eqs '^\s*lcredit\s*=' /etc/security/pwquality.conf && sed -i 's/^\s*lcredit\s*=/# &/' /etc/security/pwquality.conf
         fi
      fi

      if ! grep -Eqs '^\s*minclass\s*=\s*4\b' /etc/security/pwquality.conf; then
         if grep -Eqs '^\s*(#\s*)?minclass\s*=' /etc/security/pwquality.conf; then
            echo -e "- Updating minclass entry in /etc/security/pwquality.conf" | tee -a "$LOG" 2>> "$ELOG"
            sed -ri 's/^\s*(#\s*)?(minclass\s*=)(\s*\S+\s*)(\s+#.*)?$/\2 4\4/' /etc/security/pwquality.conf
         else
            echo -e "- Adding minclass entry to /etc/security/pwquality.conf" | tee -a "$LOG" 2>> "$ELOG"
            echo "minclass = 4" >> /etc/security/pwquality.conf
         fi
      fi

      test=remediated

      echo -e "- End remediation - Ensure password complexity is configured " | tee -a "$LOG" 2>> "$ELOG"
   }

   fed_ensure_password_complexity_configured_chk
   if [ $? -eq 101 ]; then
      [ -z "$test" ] && test="passed"
   else
      if [ "$test" != "NA" ]; then
         fed_ensure_password_complexity_configured_fix
         if [ "$test" != "manual" ]; then
            fed_ensure_password_complexity_configured_chk
            if [ $? -eq 101 ]; then
                    [ "$test" != "failed" ] && test="remediated"
                else
                    test="failed"
            fi
         fi   
      fi
   fi

   # Set return code, end recommendation entry in verbose log, and return
   case "$test" in
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