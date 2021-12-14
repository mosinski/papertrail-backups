#!/bin/bash

# terminate script as soon as any command fails
set -e

if [[ -z "$FTP_HOST" ]]; then
  echo "Missing FTP_HOST variable which must be set to the FTP host url"
  exit 1
fi

if [[ -z "$FTP_USER" ]]; then
  echo "Missing FTP_USER variable which must be set to the FTP account username"
  exit 1
fi

if [[ -z "$FTP_PASSWORD" ]]; then
  echo "Missing FTP_PASSWORD variable which must be set to the FTP account password"
  exit 1
fi

if [[ -z "$FTP_DIRECTORY" ]]; then
  echo "Missing FTP_DIRECTORY variable which must be set to the FTP directory path where you would like to store your logs backups"
  exit 1
fi

if [[ -z "$HTTP_API_KEY" ]]; then
  echo "Missing HTTP_API_KEY variable which must be set to the Papertrail API Token"
  exit 1
fi

if [[ -z "$LOG_FORMAT" ]]; then
  echo "Missing LOG_FORMAT using default '%Y-%m-%d-%H'"
  LOG_FORMAT="%Y-%m-%d-%H"
fi

TMP_LOG_FILE="papertrail"
FTP_LOG_FILE="$(date -d -8hours +$LOG_FORMAT)"
FTP_URL="ftp://$FTP_HOST/$FTP_DIRECTORY"

PAPERTRAIL_LOG_FILE="$(date -d -8hours +"%Y-%m-%d-%H")"
PAPERTRAIL_API_URL="https://papertrailapp.com/api/v1/archives/$PAPERTRAIL_LOG_FILE/download"

if [ -f $TMP_LOG_FILE.tsv ]; then
  echo "Remove old tmp log file"
  rm $TMP_LOG_FILE.tsv
fi

if [ -f $FTP_LOG_FILE.tsv ]; then
  echo "Remove old ftp log file"
  rm $FTP_LOG_FILE.tsv
fi

echo "Download archive from papertrail"
curl --no-include -o $TMP_LOG_FILE.tsv.gz -L -H "X-Papertrail-Token: $HTTP_API_KEY" $PAPERTRAIL_API_URL 2>/dev/null
gunzip $TMP_LOG_FILE.tsv.gz

if ! wget --user=$FTP_USER --password=$FTP_PASSWORD -q $FTP_URL$FTP_LOG_FILE.tsv; then
  echo "Create log file"
  touch $FTP_LOG_FILE.tsv
fi

echo "Merging two files"
cat $TMP_LOG_FILE.tsv >> $FTP_LOG_FILE.tsv

echo "Upload update log file"
curl -v --user $FTP_USER:$FTP_PASSWORD --upload-file $FTP_LOG_FILE.tsv $FTP_URL 2>/dev/null

echo -e "Backup $FTP_LOG_FILE.tsv complete \xF0\x9F\x8E\x89"
