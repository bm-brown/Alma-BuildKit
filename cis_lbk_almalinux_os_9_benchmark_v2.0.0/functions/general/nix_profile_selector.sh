#!/usr/bin/env bash
#
# CIS-LBK Remediation function
# ~/CIS-LBK/functions/general/nix_profile_selector.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Patrick Araya      10/05/20    Selects the appropriate profile based on the commandline switch or via user interaction
# J Brown           11/25/23    Updated to support silent execution

select_profile()
{
    profile_options="L1S L1W L2S L2W"
    request_profile()
    {
        if [ "$SILENT" != "true" ]; then
            # Print options to std-out
            echo -e "Please enter the number for the desired profile: \n\t1: L1S - Level 1 Server\n\t2: L1W - Level 1 Workstation\n\t3: L2S - Level 2 Server\n\t4: L2W - Level 2 Workstation"

            read -p "Profile: " p
            profile_input=$(echo $p | tr '[:lower:]' '[:upper:]')
        else
            echo "- Using $PROFILE as desired profile from CLI parameter" | tee -a "$LOG" 2>> "$ELOG"
            profile_input="$PROFILE"
        fi

        case $profile_input in
            1|L1S|Level\ 1\ -\ Server|Level\ 1\ Server)
                echo "- Using \"L1S\" as the profile" | tee -a "$LOG" 2>> "$ELOG"
                run_profile="L1S"
                ;;
            2|L1W|Level\ 1\ -\ Workstation|Level\ 1\ Workstation)
                echo "- Using \"L1W\" as the profile" | tee -a "$LOG" 2>> "$ELOG"
                run_profile="L1W"
                ;;
            3|L2S|Level\ 2\ -\ Server|Level\ 2\ Server)
                echo "- Using \"L2S\" as the profile" | tee -a "$LOG" 2>> "$ELOG"
                run_profile="L2S"
                ;;
            4|L2W|Level\ 2\ -\ Workstation|Level\ 2\ Workstation)
                echo "- Using \"L2W\" as the profile" | tee -a "$LOG" 2>> "$ELOG"
                run_profile="L2W"
                ;;
            *)
                run_profile="unknown"
                ;;
        esac
	}
	#if run_profile doesn't exist, or isn't set to something from profile_options, prompt for user selection
    if [ -z "$run_profile" ]; then
        request_profile
    fi

    echo -e "- Validating profile selection" | tee -a "$LOG" 2>> "$ELOG"
    if ! echo "$profile_options" | grep -q "$run_profile"; then
        echo -e "- Profile selection is invalid" | tee -a "$LOG" 2>> "$ELOG"
        if [ "$SILENT" != "true" ]; then
            request_profile
        else
            echo -e "- Unknown profile passed in parameter: \"$PROFILE\"" | tee -a "$LOG" 2>> "$ELOG"
            set -e
            /bin/false
        fi
    fi
}