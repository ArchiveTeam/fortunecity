#!/bin/bash
# Script for downloading one FortuneCity site from
# http://members.fortunecity.(com|co.uk|es|it|se)/$MEMBER/
#
# Usage:   dld-member.sh ${TLD} ${MEMBER}
# where TLD is one of: com co.uk es it se
#
# Needs wget-warc.
#

VERSION="20120304.01"

tld=$1
member=$2

if [ -z $tld ] || [ -z $member ]
then
  echo "No tld or member name."
  exit 1
fi

USER_AGENT="Googlebot/2.1 (+http://www.googlebot.com/bot.html)"
USER_AGENT="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27"

prefix_dir="data/$tld/members/${member:0:1}/${member:0:2}/${member:0:3}"
member_dir="$prefix_dir/$member"

if [ -d "$prefix_dir" ] && [ ! -z "$( find "$prefix_dir/" -maxdepth 1 -type f -name "$tld-members-$member-*.warc.gz" )" ]
then
  echo "Already downloaded ${tld}/members/${member}"
  exit 2
fi

echo "Downloading ${tld}/members/${member}"

rm -rf "$member_dir"

mkdir -p "$member_dir/files"

t=$( date -u +'%Y%m%d-%H%M%S' )
warc_file_base="$tld-members-$member-$t"

./wget-warc \
  -U "$USER_AGENT" \
  -nv \
  -o "$member_dir/$tld-members-$member-$t.log" \
  -r -l inf --no-remove-listing \
  "http://members.fortunecity.$tld/$member/" \
  --page-requisites \
  --no-parent \
  --trust-server-names \
  --directory-prefix="$member_dir/files/" \
  --warc-file="$member_dir/$warc_file_base" \
  --warc-header="operator: Archive Team" \
  --warc-header="fortunecity-dld-script-version: ${VERSION}" \
  --warc-header="fortunecity: ${tld}, members, ${member}"

result=$?

if [ $result -ne 0 ] && [ $result -ne 6 ] && [ $result -ne 8 ]
then
  echo " ERROR ($result)."
  exit 1
fi

mv "$member_dir/$warc_file_base.warc.gz" "$prefix_dir/$warc_file_base.warc.gz"
rm -rf "$member_dir"

exit 0

