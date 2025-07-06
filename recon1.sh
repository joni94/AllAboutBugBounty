#!/bin/bash

# Script: website_status_checker.sh
# Description: Checks HTTP status codes of multiple websites from a list.
# Usage: ./website_status_checker.sh <input_file.txt>

# Check if input file is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <target_domain_string> <include_subdomain_bool> <https_bool> <wordlist_txt>"
    exit 1
fi

TARGET_DOMAIN="$1"
INCLUDE_DOMAIN="$2"
HTTPS_BOOL="$3"
RESULT_FOLDER="/home/kali/Documents/Results/Result_$1"
WORD_LIST="/home/kali/Documents/Busting/$4";

if [ -d $RESULT_FOLDER ]; then
    echo "Result directory exists, no action taken - $RESULT_FOLDER"
else
    echo "Creating Results Folder in $RESULT_FOLDER"
    mkdir "$RESULT_FOLDER"
fi




# Check if file exists
# if [ ! -f "$INPUT_FILE" ];  then
#     echo "Error: File '$INPUT_FILE' not found!"
#     exit 1
# fi

if [ "$2" -eq 1 ]; then
    echo "Executing Subfinder and Sublist3r for $1"
    subfinder -d $1 -o $RESULT_FOLDER/subf_$1.txt & 
    sublist3r -d $1 -o $RESULT_FOLDER/subl_$1.txt
    wait
    cat $RESULT_FOLDER/subf_$1.txt $RESULT_FOLDER/subl_$1.txt | sort -u > $RESULT_FOLDER/all_subs_$1.txt
fi

echo "Executing FFUF with wordlist: $WORD_LIST"
if [ "$3" -eq 1 ]; then
ffuf -u https://$TARGET_DOMAIN/FUZZ -w $WORD_LIST -o $RESULT_FOLDER/FFUF_$1.txt -fs 1337 -fc 404
else
ffuf -u http://$TARGET_DOMAIN/FUZZ -w $WORD_LIST -o $RESULT_FOLDER/FFUF_$1.txt -fs 1337 -fc 404
fi
python3 -m json.tool $RESULT_FOLDER/FFUF_$1.txt > $RESULT_FOLDER/FFUF_$1.json 



#1 Recon Subdomains with FUFF sublist3r gobster dns WHOIS/ReverseWHOIS

#2 Recon pages on subdomains Fuff gobuster dirsearchss

#3 Service Enumaration Active/Passive

#4 Techstack Censys/Shodan/ 

#5 List CVE's possibled from Shodan/techstack info / Service infos



# User-Agent header (optional, avoids blocking)
#USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0"



# Loop through each URL in the file
# while read -r URL; do
#     # Skip empty lines
#     if [ -z "$URL" ]; then
#         continue
#     fi

#     # Add 'http://' if missing (curl fails without scheme)
#     if [[ ! "$URL" =~ ^https?:// ]]; then
#         URL="http://$URL"
#     fi

#     # Get HTTP status code using curl
#     STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}" -A "$USER_AGENT" --max-time 5 "$URL")

#     # Output result
#     case "$STATUS_CODE" in
#         200) STATUS="✅ OK" ;;
#         301|302) STATUS="🔀 Redirect" ;;
#         403) STATUS="🔒 Forbidden" ;;
#         404) STATUS="❌ Not Found" ;;
#         500) STATUS="💥 Server Error" ;;
#         *) STATUS="❓ Unknown ($STATUS_CODE)" ;;
#     esac

#     echo "$URL: $STATUS"
# done < "$INPUT_FILE"

echo "---------------------"
echo "Done!"