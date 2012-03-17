Things for downloading FortuneCity.com (and .it, .es, .se, .co.uk).

Installation
------------
Clone the git repository:

    git clone git://github.com/ArchiveTeam/fortunecity.git

You need wget-warc (as always):

    ./get-wget-warc.sh

Usage
-----
Run a download client:

    ./seesaw.sh YOURNICK

To stop your script, don't just kill it. Instead:

    touch STOP

and the script will end gracefully after the current item.

If it works you may run a few more clients. But don't run more than 10.

