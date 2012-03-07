#!/bin/bash
# Downloads a single user or street and tells the tracker it's done.
# This can be handy if dld-client.sh failed and you'd like to retry
# the item.
#
# Usage:   dld-single.sh ${YOURALIAS} ${ITEM}
#
# Item names are:   ${TLD}/${AREA}/${STREET}  for streets
#                   ${TLD}/member/${MEMBER}   for members

youralias="$1"
itemname="$2"

if [[ ! $youralias =~ ^[-A-Za-z0-9_]+$ ]]
then
  echo "Usage:  $0 {yournick} {itemtodownload}"
  echo "Run with a nickname with only A-Z, a-z, 0-9, - and _"
  exit 4
fi

if [ -z $itemname ]
then
  echo "Usage:  $0 {yournick} {itemtodownload}"
  echo "Provide an item."
  exit 5
fi

VERSION=$( grep 'VERSION=' dld-member.sh | grep -oE "[-0-9.]+" )

tld=$( echo "$itemname" | cut -d "/" -f 1 )
area=$( echo "$itemname" | cut -d "/" -f 2 )
street=$( echo "$itemname" | cut -d "/" -f 3 )

if [ $area == member ] || [ $area == members ]
then
  ./dld-member.sh "$tld" "$street"
  result=$?
else
  ./dld-street.sh "$tld" "$area" "$street"
  result=$?
fi

if [ $result -eq 0 ]
then
  # complete

  # statistics!
  if [ $area == member ] || [ $area == members ]
  then
    prefix_dir="data/$tld/members/${street:0:1}/${street:0:2}/${street:0:3}"
    bytes=$( ./du-helper.sh -b "$prefix_dir/$tld-members-$street-"*".warc.gz" )
    bytes_str="{\"member\":${bytes},\"street\":0}"
  else
    prefix_dir="data/$tld/$area"
    bytes=$( ./du-helper.sh -b "$prefix_dir/$tld-$area-$street-"*".warc.gz" )
    bytes_str="{\"member\":0,\"street\":${bytes}}"
  fi

  success_str="{\"downloader\":\"${youralias}\",\"item\":\"${itemname}\",\"bytes\":${bytes_str},\"version\":\"${VERSION}\",\"id\":\"\"}"

  delay=1
  while [ $delay -gt 0 ]
  do
    echo "Telling tracker that '${itemname}' is done."
    tracker_no=$(( RANDOM % 3 ))
    tracker_host="focity-${tracker_no}.heroku.com"
    resp=$( curl -s -f -d "$success_str" http://${tracker_host}/done )
    if [[ "$resp" != "OK" ]]
    then
      echo "ERROR contacting tracker. Could not mark '$itemname' done."
      echo "Sleep and retry."
      sleep $delay
      delay=$(( delay * 2 ))
    else
      delay=0
    fi
  done
  echo
else
  echo "Error downloading '$itemname'."
  exit 6
fi

