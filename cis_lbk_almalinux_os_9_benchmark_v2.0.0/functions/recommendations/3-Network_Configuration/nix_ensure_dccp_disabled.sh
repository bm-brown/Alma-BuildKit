#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 420934c5
#   function = ensure_dccp_disabled
#   applicable =
# # END METADATA
#
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_dccp_disabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Justin Brown       11/19/22    Recommendation "Ensure DCCP is disabled"
# Justin Brown       06/21/23    Update to add type support 

ensure_dccp_disabled()
{
   echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
   l_test=""
   l_mname="dccp" # set module name
   l_mtype="net" # set module type
   l_searchloc="/lib/modprobe.d/*.conf /usr/local/lib/modprobe.d/*.conf /run/modprobe.d/*.conf /etc/modprobe.d/*.conf"
   l_mpath="/lib/modules/**/kernel/$l_mtype"
   l_mpname="$(tr '-' '_' <<< "$l_mname")"
   l_mndir="$(tr '-' '/' <<< "$l_mname")"

   module_loadable_chk()
   {
      # Check if the module is currently loadable
      l_loadable="$(modprobe -n -v "$l_mname")"
      [ "$(wc -l <<< "$l_loadable")" -gt "1" ] && l_loadable="$(grep -P -- "(^\h*install|\b$l_mname)\b" <<< "$l_loadable")"
      if grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
         l_output="$l_output\n - module: \"$l_mname\" is not loadable: \"$l_loadable\""
      else
         l_output2="$l_output2\n - module: \"$l_mname\" is loadable: \"$l_loadable\""
      fi
   }

   module_loaded_chk()
   {
      # Check if the module is currently loaded
      if ! lsmod | grep "$l_mname" > /dev/null 2>&1; then
         l_output="$l_output\n - module: \"$l_mname\" is not loaded"
      else
         l_output2="$l_output2\n - module: \"$l_mname\" is loaded"
      fi
   }

   module_deny_chk()
   {
      # Check if the module is deny listed
      l_dl="y"
      if modprobe --showconfig | grep -Pq -- '^\h*blacklist\h+'"$l_mpname"'\b'; then
         l_output="$l_output\n - module: \"$l_mname\" is deny listed in: \"$(grep -Pls -- "^\h*blacklist\h+$l_mname\b" $l_searchloc)\""
      else
         l_output2="$l_output2\n - module: \"$l_mname\" is not deny listed"
      fi
   }

   module_loadable_fix()
   {
      # If the module is currently loadable, add "install {MODULE_NAME} /bin/false" to a file in "/etc/modprobe.d"
      l_loadable="$(modprobe -n -v "$l_mname")"
      [ "$(wc -l <<< "$l_loadable")" -gt "1" ] && l_loadable="$(grep -P -- "(^\h*install|\b$l_mname)\b" <<< "$l_loadable")"
      if ! grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
         echo -e "\n - setting module: \"$l_mname\" to be not loadable"
         echo -e "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mpname".conf
      fi
   }

   module_loaded_fix()
   {
      # If the module is currently loaded, unload the module
      if lsmod | grep "$l_mname" > /dev/null 2>&1; then
         echo -e "\n - unloading module \"$l_mname\""
         modprobe -r "$l_mname"
      fi
   }

   module_deny_fix()
   {
      # If the module isn't deny listed, denylist the module
      if ! modprobe --showconfig | grep -Pq -- "^\h*blacklist\h+$l_mpname\b"; then
         echo -e "\n - deny listing \"$l_mname\""
         echo -e "blacklist $l_mname" >> /etc/modprobe.d/"$l_mpname".conf
      fi
   }

   ensure_dccp_disabled_chk()
   {
      echo -e "- Start check - Ensure DCCP is disabled" | tee -a "$LOG" 2>> "$ELOG"

      l_output="" l_output2="" l_output3="" l_dl="" # Unset output variables
      # Check if the module exists on the system
      for l_mdir in $l_mpath; do
         if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A $l_mdir/$l_mndir)" ]; then
            l_output3="$l_output3\n  - \"$l_mdir\""
            [ "$l_dl" != "y" ] && module_deny_chk
            if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
               module_loadable_chk
               module_loaded_chk
            fi
         else
            l_output="$l_output\n - module: \"$l_mname\" doesn't exist in \"$l_mdir\""
         fi
      done

      # Report results. If no failures output in l_output2, we pass
      [ -n "$l_output3" ] && echo -e "\n\n -- INFO --\n - module: \"$l_mname\" exists in:$l_output3"
      if [ -z "$l_output2" ]; then
         echo -e "\n- Audit Result:\n  ** PASS **\n$l_output\n"
         echo -e "- End check - Ensure DCCP is disabled" | tee -a "$LOG" 2>> "$ELOG"
         return "${XCCDF_RESULT_PASS:-101}"
      else
         echo -e "\n- Audit Result:\n  ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
         [ -n "$l_output" ] && echo -e "\n- Correctly set:\n$l_output\n"
         echo -e "- End check - Ensure DCCP is disabled" | tee -a "$LOG" 2>> "$ELOG"
         return "${XCCDF_RESULT_FAIL:-102}"
      fi
   }

   ensure_dccp_disabled_fix()
   {
      echo -e "- Start remediation - Ensure DCCP is disabled" | tee -a "$LOG" 2>> "$ELOG"

      # Check if the module exists on the system
   for l_mdir in $l_mpath; do
      if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A $l_mdir/$l_mndir)" ]; then
         echo -e "\n - module: \"$l_mname\" exists in \"$l_mdir\"\n - checking if disabled..."
         module_deny_fix
         if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
            module_loadable_fix
            module_loaded_fix
         fi
      else
         echo -e "\n - module: \"$l_mname\" doesn't exist in \"$l_mdir\"\n"
      fi
   done
   echo -e "\n - remediation of module: \"$l_mname\" complete\n"

      echo -e "- End remediation - Ensure DCCP is disabled" | tee -a "$LOG" 2>> "$ELOG"
   }

   ensure_dccp_disabled_chk
   if [ "$?" = "101" ]; then
      [ -z "$l_test" ] && l_test="passed"
   else
      ensure_dccp_disabled_fix
      if [ "$l_test" != "manual" ]; then
         ensure_dccp_disabled_chk
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