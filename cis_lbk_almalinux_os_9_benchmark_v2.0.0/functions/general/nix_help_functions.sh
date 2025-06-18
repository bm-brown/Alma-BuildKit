#!/bin/bash
#
# CIS-LBK general Function
# ~/CIS-LBK/functions/general/help_functions.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# J Brown           11/25/23    General Help Functions
#

CLI_HELP()
{
   # Display Help
   echo "Build Kit Script Help"
   echo
   echo "Syntax: buildkit_script_name.sh [-h|s|p]"
   echo "options:"
   echo
   echo "-h     Print this Help."
   echo "-s     Enable silent mode (Must be used with -p)"
   echo "-p     Profile (Profile should be passe as the Profile name from the benchmark i.e \"Level 1 - Server\")"
   echo
   echo "EXAMPLE: buildkit_script_name.sh -s -p \"Level 1 Server\""
   echo
   echo "If no options are provided the script will execute in standard interactive mode."
   echo
}