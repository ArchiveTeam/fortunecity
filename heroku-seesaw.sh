#!/bin/bash
#
# Running seesaw.sh on Heroku.
#
# $ heroku create $YOURAPP --stack cedar --buildpack "https://github.com/ArchiveTeam/heroku-buildpack-archiveteam.git"
# $ heroku config:set YOURALIAS=$YOURALIAS
# $ git push heroku -u master
# $ heroku ps:scale seesaw=1
#

YOURALIAS=$1

if [ -z $YOURALIAS ]
then
  echo "The YOURALIAS variable is not set."
  exit
fi

if [ ! -x ./wget-warc ]
then
  echo "Where is wget-warc? Where is the buildpack?"
  exit 3
fi

run_an_instance() {
  while [ ! -f STOP ]
  do
    PATH=../bin:$PATH ./seesaw.sh $YOURALIAS
  done
}

run_an_instance &
run_an_instance &
run_an_instance &
run_an_instance &

while true
do
  sleep 60
done

