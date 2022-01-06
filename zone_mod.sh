#!/bin/bash
# Example
# $ ./zone_mod.sh add (for adding)
# $ ./zone_mod.sh del (for deleting)

ZONEID=ZXXXXXXXXXXXXXXXX #add yours here..

# Because AWS CLI command results are dumped to terminal
# in JSON format, I needed to carve out the change ID and
# stuff it in a variable I could use.

read JOBID < <(aws route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://record_$1.json | grep change | awk -F '"' '{print $4}' | awk -F '/' '{print $3}'); 
# wait for zone to sync...up to 30 seconds (5 x 6)
for checker in {1..5};
do	
	read JOBRES < <(aws route53 get-change --id /change/$JOBID | grep Status | awk -F '"' '{print $4}');
	if [[ "$JOBRES" == "INSYNC" ]]; then
		echo $JOBRES;
		break
	elif [[ "$JOBRES" == "PENDING" ]]; then
		echo $JOBRES;
		sleep 6;
		continue
	else
		echo "ERROR";
		break
	fi
done
