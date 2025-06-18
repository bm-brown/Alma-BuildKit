#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = e062944b
#   function = ensure_crontab_restricted_authorized_users
#   applicable =
# # END METADATA
#
#
# CIS-LBK _Main Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_crontab_restricted_authorized_users.sh
#
# Name                  Date            Description
# --------------------------------------------------------------------------------------------------------
# J Brown               02/21/24        Recommendation "Ensure crontab is restricted to authorized users"
# David Neilson         07/02/24        Set l_test variable instead of running the "return" command if package manager is unknown or cron not installed, changed references of "0600" to "0640", added additional logging, and remediates for group "crontab".
#

ensure_crontab_restricted_authorized_users()
{
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test="" l_pkg=""

	nix_package_manager_set()
    {
        echo -e "- Start - Determine system's package manager " | tee -a "$LOG" 2>> "$ELOG"
        if command -v rpm &>/dev/null; then
            echo -e "- system is rpm based" | tee -a "$LOG" 2>> "$ELOG"
            G_PQ="rpm -q"
            command -v yum &> /dev/null && G_PM="yum" && echo -e "- system uses yum package manager" | tee -a "$LOG" 2>> "$ELOG"
            command -v dnf &> /dev/null && G_PM="dnf" && echo -e "- system uses dnf package manager" | tee -a "$LOG" 2>> "$ELOG"
            command -v zypper &> /dev/null && G_PM="zypper" && echo -e "- system uses zypper package manager" | tee -a "$LOG" 2>> "$ELOG"
            G_PR="$G_PM remove -y"
            export G_PQ G_PM G_PR
            echo -e "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        elif command -v dpkg &> /dev/null; then
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

	ensure_crontab_restricted_authorized_users_chk()
	{
		echo -e "- Start check - Ensure crontab is restricted to authorized users" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        if [ -f "/etc/cron.allow" ]; then
            if stat -Lc "%a" /etc/cron.allow | grep -Pq -- '^\h*[0-6][0-4]0\h*$'; then
                l_output="$l_output\n- /etc/cron.allow permissions are: '$(stat -Lc "%a" /etc/cron.allow)'"
            else
                l_output2="$l_output2\n- /etc/cron.allow permissions are: '$(stat -Lc "%a" /etc/cron.allow)' and should be '640' or more strict"
            fi

            if stat -Lc "%U %G" /etc/cron.allow | grep -Pq -- '^\h*root\h+(root|crontab)\h*$'; then
                l_output="$l_output\n- /etc/cron.allow ownership is: '$(stat -Lc "%U:%G" /etc/cron.allow)'"
            else
                l_output2="$l_output2\n- /etc/cron.allow ownership is: '$(stat -Lc "%U:%G" /etc/cron.allow)' and should be 'root:root'"
            fi
        else
            l_output2="$l_output2\n- '/etc/cron.allow' doesn't exist"
        fi

        if [ -f "/etc/cron.deny" ]; then
            if stat -Lc "%a" /etc/cron.deny | grep -Pq -- '^\h*[0-6][0-4]0\h*$'; then
                l_output="$l_output\n- /etc/cron.deny permissions are: '$(stat -Lc "%a" /etc/cron.deny)'"
            else
                l_output2="$l_output2\n- /etc/cron.deny permissions are: '$(stat -Lc "%a" /etc/cron.deny)' and should be '640' or more strict"
            fi

            if stat -Lc "%U %G" /etc/cron.deny | grep -Pq -- '^\h*root\h+(root|crontab)\h*$'; then
                l_output="$l_output\n- /etc/cron.deny ownership is: '$(stat -Lc "%U:%G" /etc/cron.deny)'"
            else
                l_output2="$l_output2\n- /etc/cron.deny ownership is: '$(stat -Lc "%U:%G" /etc/cron.deny)' and should be 'root:root'"
            fi
		else
			l_output="$l_output\n- '/etc/cron.deny' doesn't exist"
		fi

		if [ -z "$l_output2" ]; then
			echo -e "- PASS: Permissions for cron.allow and cron.deny are correct" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- Passing Value:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure crontab is restricted to authorized users" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL: Permissions for cron.allow and cron.deny are NOT correct" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- Failing Value:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            if [ -n "$l_output" ]; then
                echo -e "- Passing Value:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            fi
			echo -e "- End check - Ensure crontab is restricted to authorized users" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

	ensure_crontab_restricted_authorized_users_fix()
	{
		echo -e "- Start remediation - Ensure crontab is restricted to authorized users" | tee -a "$LOG" 2>> "$ELOG"

        if [ ! -f "/etc/cron.allow" ]; then
			echo -e "- Creating: '/etc/cron.allow'" | tee -a "$LOG" 2>> "$ELOG"
			touch "/etc/cron.allow"
        fi

		if [ -f "/etc/cron.allow" ]; then
			if ! stat -Lc "%a" /etc/cron.allow | grep -Pq -- '^\h*[0-6][0-4]0\h*$'; then
				echo -e "- Removing excess permissions from '/etc/cron.allow'" | tee -a "$LOG" 2>> "$ELOG"
				chmod u-x,g-wx,o-rwx "/etc/cron.allow"
			fi

			if ! stat -Lc "%U %G" /etc/cron.allow | grep -Pq -- '^\h*root\h+(root|crontab)\h*$'; then
				echo -e "- Setting ownership on '/etc/cron.allow'" | tee -a "$LOG" 2>> "$ELOG"
                if grep -Pq -- '^\h*crontab\:' /etc/group; then
                    chown root:crontab /etc/cron.allow
                else
      				chown root:root /etc/cron.allow
			    fi
            fi
		fi

        if [ -f "/etc/cron.deny" ]; then
			if ! stat -Lc "%a" /etc/cron.deny | grep -Pq -- '^\h*[0-6][0-4]0\h*$'; then
				echo -e "- Removing excess permissions from '/etc/cron.deny'" | tee -a "$LOG" 2>> "$ELOG"
				chmod u-x,g-wx,o-rwx /etc/cron.deny
			fi

			if ! stat -Lc "%U %G" /etc/cron.deny | grep -Pq -- '^\h*root\h+(root|crontab)\h*$'; then
				echo -e "- Setting ownership on '/etc/cron.deny'" | tee -a "$LOG" 2>> "$ELOG"
                if grep -Pq -- '^\h*crontab\:' /etc/group; then
                    chown root:crontab /etc/cron.deny
                else
				    chown root:root /etc/cron.deny
                fi
			fi
		fi

		echo -e "- End remediation - Ensure crontab is restricted to authorized users" | tee -a "$LOG" 2>> "$ELOG"
	}

	# Set package manager information
    if [ -z "$G_PQ" ] || [ -z "$G_PM" ] || [ -z "$G_PR" ]; then
        nix_package_manager_set
        [ $? -ne 101 ] && l_pkg="false"
    fi

    # Determine if cron or cronie is installed.  If it is, run the chk and fix subfunctions.
    echo -e "- Determining if cron is installed on the system" | tee -a "$LOG" 2>> "$ELOG"
    if [ "$l_pkg" != "false" ] && ( $G_PQ cron &> /dev/null || $G_PQ cronie &> /dev/null ); then
        ensure_crontab_restricted_authorized_users_chk
        if [ $? -eq 101 ]; then
            [ -z "$l_test" ] && l_test="passed"
        else
            ensure_crontab_restricted_authorized_users_fix
            if [ "$l_test" != "manual" ]; then
                ensure_crontab_restricted_authorized_users_chk
                if [ $? -eq 101 ]; then
                    [ "$l_test" != "failed" ] && l_test="remediated"
                else
                    l_test="failed"
                fi
            fi
        fi
    else
        if [ "$l_pkg" = "false" ]; then
            l_test="manual"
            echo -e "- MANUAL:\n- Unable to determine system's package manager"  | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure crontab is restricted to authorized users" | tee -a "$LOG" 2>> "$ELOG"
        else
            [ -z "$l_test" ] && l_test="NA"
            echo -e "- PASS:\n- cron is not installed"  | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure crontab is restricted to authorized users" | tee -a "$LOG" 2>> "$ELOG"
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