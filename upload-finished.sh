#!/bin/bash
#
# Upload complete files to the Fortress of Solitude.
#
# This script will look in your data/ directory to find
# users that are finished. It will upload the data for
# these users to the repository using rsync.
#
# You can run this while you're still downloading,
# since it will only upload data that is done.
#
# Usage:
#   ./upload-finished.sh $YOURNICK
#
# You can set a bwlimit for rsync, e.g.:
#   ./upload-finished.sh $YOURNICK 300
#

destname=$1
target=fos
dest=${target}.textfiles.com::fortunecity/$1/
if [ -z "$destname" ]
then
  echo "Usage:  $0 [yournick] [bwlimit]"
  exit
fi
if [[ ! $destname =~ ^[-A-Za-z0-9_]+$ ]]
then
  echo "$dest does not look like a proper nickname."
  echo "Usage:  $0 [yournick] [bwlimit]"
  exit
fi

bwlimit=$2
if [ -n "$bwlimit" ]
then
  if [[ ! $bwlimit =~ ^[1-9][0-9]*$ ]]
  then
    echo "invalid bwlimit value specified."
    echo "Usage  $0 [yournick] [bwlimit]"
    exit
  fi
  bwlimit="--bwlimit=${bwlimit}"
fi

# note: DO NOT USE --partial !
cd data/
# ls -1 */members/?/??/???/*.warc.gz */*/*.warc.gz | \
find . -name "*.warc.gz" | grep -E "^\./[^/]+\/(members/./../.../|[^/]+/)[^/]+\.warc\.gz" | \
rsync -avz \
      --compress-level=9 \
      --progress \
      ${bwlimit} \
      --recursive \
      --files-from="-" \
      ./ ${dest}

exit 0

