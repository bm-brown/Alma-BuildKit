#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = c5fd912f
#   function = fed_ensure_permissions_sshd_config_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_permissions_sshd_config_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/22/20    Recommendation "Ensure permissions on /etc/ssh/sshd_config are configured"
# Justin Brown		 05/03/22    Update to modern format.
#

fed_ensure_permissions_sshd_config_configured()
{
	l_test=""

	# Checks for $sshd_config_file permissions
	# Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"

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

	fed_ensure_permissions_sshd_config_configured_chk()
	{
		l_output="" l_output2=""

        unset a_sshdfiles && a_sshdfiles=()

        [ -e "/etc/ssh/sshd_config" ] && a_sshdfiles+=("$(stat -Lc '%n^%#a^%U^%G' "/etc/ssh/sshd_config")")
        while IFS= read -r -d $'\0' l_file; do
            [ -e "$l_file" ] && a_sshdfiles+=("$(stat -Lc '%n^%#a^%U^%G' "$l_file")")
        done < <(find /etc/ssh/sshd_config.d -type f  \( -perm /077 -o ! -user root -o ! -group root \) -print0)

        if (( ${#a_sshdfiles[@]} != 0 )); then
            perm_mask='0177'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            while IFS="^" read -r l_file l_mode l_user l_group; do
                l_out2=""
                [ $(( $l_mode & $perm_mask )) -gt 0 ] && l_out2="$l_out2\n  - Is mode: \"$l_mode\" should be: \"$maxperm\" or more restrictive"
                [ "$l_user" != "root" ] && l_out2="$l_out2\n  - Is owned by \"$l_user\" should be owned by \"root\""
                [ "$l_group" != "root" ] && l_out2="$l_out2\n  - Is group owned by \"$l_user\" should be group owned by \"root\""
                if [ -n "$l_out2" ]; then
                    l_output2="$l_output2\n - File: \"$l_file\":$l_out2"
                else
                    l_output="$l_output\n - File: \"$l_file\":\n  - Correct: mode ($l_mode), owner ($l_user), and group owner ($l_group) configured"
                fi
            done <<< "$(printf '%s\n' "${a_sshdfiles[@]}")"
        fi

        unset a_sshdfiles

        # If l_output2 is empty, we pass
        if [ -z "$l_output2" ]; then
            echo -e "\n- Audit Result:\n  *** PASS ***\n- * Correctly set * :\n$l_output\n" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure permissions on /etc/ssh/sshd_config are configured." | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "\n- Audit Result:\n  ** FAIL **\n - * Reasons for audit failure * :\n$l_output2\n" | tee -a "$LOG" 2>> "$ELOG"
            [ -n "$l_output" ] && echo -e " - * Correctly set * :\n$l_output\n" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure permissions on /etc/ssh/sshd_config are configured." | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
        fi
	}

	fed_ensure_permissions_sshd_config_configured_fix()
	{
		echo -e "- Start remediation - Ensure permissions on /etc/ssh/sshd_config are configured" | tee -a "$LOG" 2>> "$ELOG"

        if [ ! -f /etc/ssh/sshd_config ]; then
			echo -e "- creating \"/etc/ssh/sshd_config\""
			touch /etc/ssh/sshd_config
		fi

		if [ -f /etc/ssh/sshd_config ]; then
			if ! stat -Lc "%a" /etc/ssh/sshd_config | grep -Pq -- '^\h*[0,2,4,6]00\h*$'; then
				echo -e "- Removing excess permissions from \"/etc/ssh/sshd_config\"" | tee -a "$LOG" 2>> "$ELOG"
				chmod u-x,og-rwx /etc/ssh/sshd_config
			fi

			if ! stat -Lc "%U %G" /etc/ssh/sshd_config | grep -Pq -- '^\h*root\h+root\h*$'; then
				echo -e "- Setting ownership on \"/etc/ssh/sshd_config\"" | tee -a "$LOG" 2>> "$ELOG"
				chown root:root /etc/ssh/sshd_config
			fi
		fi

        while IFS= read -r -d $'\0' l_file; do
            if [ -e "$l_file" ]; then
                if ! stat -Lc "%a" "$l_file" | grep -Pq -- '^\h*[0,2,4,6]00\h*$'; then
                    echo -e "- Removing excess permissions from \"$l_file\"" | tee -a "$LOG" 2>> "$ELOG"
                    chmod u-x,og-rwx "$l_file"
                fi
                if ! stat -Lc "%U %G" "$l_file" | grep -Pq -- '^\h*root\h+root\h*$'; then
                    echo -e "- Setting ownership on \"$l_file\"" | tee -a "$LOG" 2>> "$ELOG"
                    chown root:root "$l_file"
                fi
            fi
        done < <(find /etc/ssh/sshd_config.d -type f -print0)

		echo -e "- End remediation - Ensure permissions on /etc/ssh/sshd_config are configured" | tee -a "$LOG" 2>> "$ELOG"
	}

	# Check is package manager is defined
	if [ -z "$G_PQ" ] || [ -z "$G_PM" ] || [ -z "$G_PR" ]; then
		nix_package_manager_set
		[ "$?" = "102" ] && l_test="manual"
	fi

	# Check is openssh-server is installed
	if ! $G_PQ openssh-server >/dev/null; then
		l_test="NA"
	else
		fed_ensure_permissions_sshd_config_configured_chk
		if [ "$?" = "101" ]; then
			[ -z "$l_test" ] && l_test="passed"
		else
			fed_ensure_permissions_sshd_config_configured_fix
			fed_ensure_permissions_sshd_config_configured_chk
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