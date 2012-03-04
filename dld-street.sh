#!/bin/bash
# Script for downloading one FortuneCity street from
# http://www.fortunecity.(com|co.uk|es|it|se)/$AREA/$STREET/
#
# Usage:   dld-street.sh ${TLD} ${AREA} ${STREET}
# where TLD is one of: com co.uk es it se
#
# Needs wget-warc.
#

VERSION="20120304.01"

tld=$1
area=$2
street=$3

if [ -z $tld ] || [ -z $area ] || [ -z $street ]
then
  echo "No tld, area or street name."
  exit 1
fi

USER_AGENT="Googlebot/2.1 (+http://www.googlebot.com/bot.html)"
USER_AGENT="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27"

area_dir="data/$tld/$area"
street_dir="$area_dir/$street"

if [ -d "$area_dir" ] && [ ! -z "$( find "$area_dir/" -maxdepth 1 -type f -name "$tld-$area-$street-*.warc.gz" )" ]
then
  echo "Already downloaded ${tld}/${area}/${street}"
  exit 0
fi

echo "Downloading ${tld}/${area}/${street}"

rm -rf "$street_dir"

mkdir -p "$street_dir/files"

echo "http://www.fortunecity.$tld/$area/$street/" > "$street_dir/urls.txt"
for i in $( seq 0 2600 )
do
  echo "http://www.fortunecity.$tld/$area/$street/$i/"
done >> "$street_dir/urls.txt"

t=$( date -u +'%Y%m%d-%H%M%S' )
warc_file_base="$tld-$area-$street-$t"

./wget-warc \
  -U "$USER_AGENT" \
  -nv \
  -o "$street_dir/$tld-$area-$street-$t.log" \
  -r -l inf --no-remove-listing \
  --page-requisites \
  --no-parent \
  --trust-server-names \
  -i "$street_dir/urls.txt" \
  --directory-prefix="$street_dir/files/" \
  --warc-file="$street_dir/$warc_file_base" \
  --warc-header="operator: Archive Team" \
  --warc-header="fortunecity-dld-script-version: ${VERSION}" \
  --warc-header="fortunecity: ${tld}, ${area}, ${street}"

result=$?

if [ $result -ne 0 ] && [ $result -ne 6 ] && [ $result -ne 8 ]
then
  echo " ERROR ($result)."
  exit 1
fi

mv "$street_dir/$warc_file_base.warc.gz" "$area_dir/$warc_file_base.warc.gz"
rm -rf "$street_dir"

exit 0

