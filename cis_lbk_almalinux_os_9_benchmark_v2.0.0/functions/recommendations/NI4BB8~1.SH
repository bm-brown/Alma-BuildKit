#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 2b552486
#   function = ensure_permissions_ssh_public_hostkey_files_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_permissions_ssh_public_hostkey_files_configured.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/22/20    Recommendation "Ensure permissions on SSH public host key files are configured"
# Justin Brown       05/14/22    Updated to modern format
# Justin Brown       11/29/22    Refactored to align with audit and remediation from prose
# David Neilson      02/08/24    Sets l_skgn="root" if not set, and doesn't run audit or remediation functions if l_test="manual"

ensure_permissions_ssh_public_hostkey_files_configured()
{
   echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
   l_test=""
   nix_package_manager_set()
	{
		echo "- Start - Determine system's package manager " | tee -a "$LOG" 2>> "$ELOG"
		if command -v rpm 2>/dev/null; then
			echo "- system is rpm based" | tee -a "$LOG" 2>> "$ELOG"
			G_PQ="rpm -q"
			command -v yum 2>/dev/null && G_PM="yum" && echo "- system uses yum package manager" | tee -a "$LOG" 2>> "$ELOG"
			command -v dnf 2>/dev/null && G_PM="dnf" && echo "- system uses dnf package manager" | tee -a "$LOG" 2>> "$ELOG"
			command -v zypper 2>/dev/null && G_PM="zypper" && echo "- system uses zypper package manager" | tee -a "$LOG" 2>> "$ELOG"
			G_PR="$G_PM remove -y"
			export G_PQ G_PM G_PR
			echo "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		elif command -v dpkg 2>/dev/null; then
			echo -e "- system is apt based\n- system uses apt package manager" | tee -a "$LOG" 2>> "$ELOG"
			G_PQ="dpkg -s"
			G_PM="apt"
			G_PR="$G_PM -y purge"
			export G_PQ G_PM G_PR
			echo "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL:\n- Unable to determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			G_PQ="unknown"
			G_PM="unknown"
			export G_PQ G_PM G_PR
			echo "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

   ensure_permissions_ssh_public_hostkey_files_configured_chk()
	{
      echo -e "- Start check - Ensure permissions on SSH public host key files are configured" | tee -a "$LOG" 2>> "$ELOG"
      l_output="" l_output2=""

      l_skgn="$(grep -Po -- '^(ssh_keys|_?ssh)\b' /etc/group)" # Group designated to own openSSH public keys
      l_skgid="$(awk -F: '($1 == "'"$l_skgn"'"){print $3}' /etc/group)" # Get gid of group

      [ -n "$l_skgid" ] && l_agroup="(root|$l_skgn)" || l_agroup="root"

      if command -v ssh-keygen &>/dev/null; then
         unset a_skarr && a_skarr=() # Clear and initialize array
         if [ -d "/etc/ssh" ]; then
            while IFS= read -r -d $'\0' l_file; do # Loop to populate array
               if grep -Pq -- '\h+no\h+comment\b' <<< "$(ssh-keygen -l -f 2>/dev/null "$l_file")"; then
                  a_skarr+=("$(stat -Lc '%n^%#a^%U^%G^%g' "$l_file")")
               fi
            done < <(find -L /etc/ssh -xdev -type f -print0)
            if (( ${#a_skarr[@]} > 0 )); then
               while IFS="^" read -r l_file l_mode l_owner l_group l_gid; do
                  echo "File: \"$l_file\" Mode: \"$l_mode\" Owner: \"$l_owner\" Group: \"$l_group\" GID: \"$l_gid\""
                  l_out2=""
                  l_pmask="0133"
                  l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"

                  if [ $(( $l_mode & $l_pmask )) -gt 0 ]; then
                     l_out2="$l_out2\n - Mode: \"$l_mode\" should be mode: \"$l_maxperm\" or more restrictive"
                  fi
                  if [ "$l_owner" != "root" ]; then
                     l_out2="$l_out2\n - Owned by: \"$l_owner\" should be owned by \"root\""
                  fi
                  if [[ ! "$l_group" =~ $l_agroup ]]; then
                     l_out2="$l_out2\n - Owned by group \"$l_group\" should be group owned by: \"${l_agroup//|/ or }\""
                  fi
                  if [ -n "$l_out2" ]; then
                     l_output2="$l_output2\n - File: \"$l_file\"$l_out2"
                  else
                     l_output="$l_output\n - File: \"$l_file\"\n - Correct: mode ($l_mode), owner ($l_owner), and group owner ($l_group) configured"
                  fi
               done <<< "$(printf '%s\n' "${a_skarr[@]}")"
            else
               l_output=" - No public keys found in \"/etc/ssh\""
            fi
         else
            l_output="- ssh directory not found on the system"
         fi
         unset a_skarr
      else
         l_output2=" - ssh-keygen command not found\n - manual check may be required"
      fi

      if [ -z "$l_output2" ]; then
         echo -e "\n- Audit Result:\n  *** PASS ***\n- * Correctly set * :\n$l_output\n" | tee -a "$LOG" 2>> "$ELOG"
         echo -e "- End check - Ensure permissions on SSH public host key files are configured" | tee -a "$LOG" 2>> "$ELOG"
         return "${XCCDF_RESULT_PASS:-101}"
      else
         echo -e "\n- Audit Result:\n  ** FAIL **\n - * Reasons for audit failure * :\n$l_output2\n" | tee -a "$LOG" 2>> "$ELOG"
         [ -n "$l_output" ] && echo -e " - * Correctly set * :\n$l_output\n" | tee -a "$LOG" 2>> "$ELOG"
         echo -e "- End check - Ensure permissions on SSH public host key files are configured" | tee -a "$LOG" 2>> "$ELOG"
         return "${XCCDF_RESULT_FAIL:-102}"
      fi
   }

   ensure_permissions_ssh_public_hostkey_files_configured_fix()
	{
      echo -e "- Start remediation - Ensure permissions on SSH public host key files are configured" | tee -a "$LOG" 2>> "$ELOG"
      l_output="" l_output2=""

      l_skgn="$(grep -Po -- '^(ssh_keys|_?ssh)\b' /etc/group)" # Group designated to own openSSH keys
      l_skgid="$(awk -F: '($1 == "'"$l_skgn"'"){print $3}' /etc/group)" # Get gid of group
      #l_mfix="u-x,go-wx"
      if [ -n "$l_skgid" ]; then
         l_agroup="(root|$l_skgn)" && l_sgroup="$l_skgn" && l_mfix="u-x,g-wx,o-rwx"
      else
         l_agroup="root" && l_sgroup="root" && l_mfix="u-x,go-rwx"
      fi

      if command -v ssh-keygen &>/dev/null; then
         unset a_skarr && a_skarr=() # Clear and initialize array
         if [ -d /etc/ssh ]; then
            while IFS= read -r -d $'\0' l_file; do # Loop to populate array
               if grep -Pq -- '\h+no\h+comment\b' <<< "$(ssh-keygen -l -f 2>/dev/null "$l_file")"; then
                  a_skarr+=("$(stat -Lc '%n^%#a^%U^%G^%g' "$l_file")")
               fi
            done < <(find -L /etc/ssh -xdev -type f -print0)

            if (( ${#a_skarr[@]} > 0 )); then
               while IFS="^" read -r l_file l_mode l_owner l_group l_gid; do
                  l_out2=""
                  l_pmask="0133"
                  l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"

                  if [ $(( $l_mode & $l_pmask )) -gt 0 ]; then
                     l_out2="$l_out2\n - Mode: \"$l_mode\" should be mode: \"$l_maxperm\" or more restrictive\n - Revoking excess permissions"
                     chmod "$l_mfix" "$l_file"
                  fi

                  if [ "$l_owner" != "root" ]; then
                     l_out2="$l_out2\n - Owned by: \"$l_owner\" should be owned by \"root\"\n - Changing ownership to \"root\""
                     chown root "$l_file"
                  fi

                  if [[ ! "$l_group" =~ $l_agroup ]]; then
                     l_out2="$l_out2\n - Owned by group \"$l_group\" should be group owned by: \"${l_agroup//|/ or }\"\n - Changing group ownership to \"$l_sgroup\""
                     chgrp "$l_sgroup" "$l_file"
                  fi

                  [ -n "$l_out2" ] && l_output2="$l_output2\n - File: \"$l_file\"$l_out2"
               done <<< "$(printf '%s\n' "${a_skarr[@]}")"
            else
               l_output=" - No public keys found in \"/etc/ssh\""
            fi
         else
            l_output="- ssh directory not found on the system"
         fi
         unset a_skarr
      else
         l_output2=" - ssh-keygen command not found\n - manual remediation may be required"
      fi

      if [ -z "$l_output2" ]; then
         echo -e "\n- No access changes required\n" else echo -e "\n- Remediation results:\n$l_output2\n" | tee -a "$LOG" 2>> "$ELOG"
      fi

      echo -e "- End remediation - Ensure permissions on SSH public host key files are configured" | tee -a "$LOG" 2>> "$ELOG"
   }

# Check is package manager is defined
	if [ -z "$G_PQ" ] || [ -z "$G_PM" ] || [ -z "$G_PR" ]; then
		nix_package_manager_set
		[ "$?" = "102" ] && l_test="manual"
	fi
 
   if [ "$l_test" != "manual" ]; then
      # Check is openssh-server is installed
      if ! $G_PQ openssh-server >/dev/null; then
         l_test="NA"
      else
         ensure_permissions_ssh_public_hostkey_files_configured_chk
         if [ "$?" = "101" ]; then
            [ -z "$l_test" ] && l_test="passed"
         else
            if [ "$l_test" != "NA" ]; then
               ensure_permissions_ssh_public_hostkey_files_configured_fix
               ensure_permissions_ssh_public_hostkey_files_configured_chk
               if [ "$?" = "101" ]; then
                  [ "$l_test" != "failed" ] && l_test="remediated"
               fi
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