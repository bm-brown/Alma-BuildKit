#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 5331fde7
#   function = ensure_rsync_service_not_in_use
#   applicable =
# # END METADATA
#
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_rsync_service_not_in_use.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/03/20    Recommendation "Ensure rsync services are not in use"
# David Neilson	   05/11/22		Updated to latest standards
# Justin Brown			09/07/22		Small syntax changes

ensure_rsync_service_not_in_use()
{
	nix_package_manager_set()
	{
		echo -e "- Start - Determine system's package manager " | tee -a "$LOG" 2>> "$ELOG"

		if command -v rpm 2>/dev/null; then
			echo -e "- system is rpm based" | tee -a "$LOG" 2>> "$ELOG"
			G_PQ="rpm -q"
			command -v yum 2>/dev/null && G_PM="yum" && echo "- system uses yum package manager" | tee -a "$LOG" 2>> "$ELOG"
			command -v dnf 2>/dev/null && G_PM="dnf" && echo "- system uses dnf package manager" | tee -a "$LOG" 2>> "$ELOG"
			command -v zypper 2>/dev/null && G_PM="zypper" && echo "- system uses zypper package manager" | tee -a "$LOG" 2>> "$ELOG"
			G_PR="$G_PM remove -y"
			export G_PQ G_PM G_PR
			echo -e "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		elif command -v dpkg 2>/dev/null; then
			echo -e "- system is apt based\n- system uses apt package manager" | tee -a "$LOG" 2>> "$ELOG"
			G_PQ="dpkg -s"
			G_PM="apt"
			G_PR="$G_PM -y purge"
			export G_PQ G_PM G_PR
			echo -e "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL:\n- Unable to determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			G_PQ="unknown"
			G_PM="unknown"
			export G_PQ G_PM G_PR
			echo -e "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

	# Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

	ensure_rsync_service_not_in_use_chk()
	{
		l_output=""
		l_pkgmgr=""

		echo -e "- Start check - Ensure rsync services are not in use" | tee -a "$LOG" 2>> "$ELOG"

		# Set package manager information
		if [ -z "$G_PQ" ] || [ -z "$G_PM" ] || [ -z "$G_PR" ]; then
			nix_package_manager_set
			[ "$?" != "101" ] && l_output="- Unable to determine system's package manager"
		fi

		# Check to see if the rpcbind package installed.  If not, we pass.
		if [ -z "$l_output" ]; then
			case "$G_PQ" in
				*rpm*)
					if $G_PQ rsync-daemon | grep "not installed" && $G_PQ rsync | grep "not installed"; then
						echo -e "- PASSED:\n- rsync package not installed" | tee -a "$LOG" 2>> "$ELOG"
						echo -e "- End check - Ensure rsync services are not in use" | tee -a "$LOG" 2>> "$ELOG"
						return "${XCCDF_RESULT_PASS:-101}"
					elif ! systemctl is-enabled rsyncd.socket rsyncd.service 2>/dev/null | grep 'enabled' && ! systemctl is-active rsyncd.socket rsyncd.service 2>/dev/null | grep '^active'; then
						echo -e "- PASSED:\n- rsyncd services are not running or enabled" | tee -a "$LOG" 2>> "$ELOG"
						echo -e "- End check - Ensure rsync services are not in use" | tee -a "$LOG" 2>> "$ELOG"
						return "${XCCDF_RESULT_PASS:-101}"
					else
						echo -e "- FAILED:\n- rsync package installed on the system" | tee -a "$LOG" 2>> "$ELOG"
						echo -e "- End check - Ensure rsync services are not in use" | tee -a "$LOG" 2>> "$ELOG"
						return "${XCCDF_RESULT_PASS:-102}"
					fi
				;;
				*dpkg*)
					if $G_PQ rsync; then
						# If rpcbind is not installed, this command returns a "1", which means we go to the else clause and the test passes
						echo -e "- FAILED:\n- rsync package installed on the system" | tee -a "$LOG" 2>> "$ELOG"
						echo -e "- End check - Ensure rsync services are not in use" | tee -a "$LOG" 2>> "$ELOG"
						return "${XCCDF_RESULT_PASS:-102}"
					else
						echo -e "- PASSED:\n- rsync package not installed" | tee -a "$LOG" 2>> "$ELOG"
						echo -e "- End check - Ensure rsync services are not in use" | tee -a "$LOG" 2>> "$ELOG"
						return "${XCCDF_RESULT_PASS:-101}"
					fi
				;;
			esac
		else
			# If we can't determine the pkg manager, need manual remediation
			l_pkgmgr="$l_output"
			echo -e "- FAILED:\n- $l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure rsync services are not in use" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-106}"
		fi
	}

	ensure_rsync_service_not_in_use_fix()
	{
		echo -e "- Start remediation - Ensure rsync services are not in use" | tee -a "$LOG" 2>> "$ELOG"

		case "$G_PQ" in
			*rpm*)
				echo -e "- Stopping service" | tee -a "$LOG" 2>> "$ELOG"
				systemctl stop rsyncd.socket rsyncd.service
				echo -e "- Removing package" | tee -a "$LOG" 2>> "$ELOG"
				$G_PR rsync rsync-daemon
			;;
			*dpkg*)
				echo -e "- Removing package" | tee -a "$LOG" 2>> "$ELOG"
				$G_PR rsync
			;;
		esac

		echo -e "- End remediation - Ensure rsync services are not in use" | tee -a "$LOG" 2>> "$ELOG"
	}

	ensure_rsync_service_not_in_use_chk
	if [ "$?" = "101" ] ; then
		[ -z "$l_test" ] && l_test="passed"
	elif [ -n "$l_pkgmgr" ] ; then
		l_test="manual"
	else
		ensure_rsync_service_not_in_use_fix
		ensure_rsync_service_not_in_use_chk
		if [ "$?" = "101" ] ; then
			[ "$l_test" != "failed" ] && l_test="remediated"
		else
			l_test="failed"
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