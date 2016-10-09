#!/bin/sh

CURIP=$(cat ~/Scripts/myip.txt)
NEWIP=$(curl -s icanhazip.com) 

if [ "$CURIP" != "$NEWIP" ];
then
        echo "Oh no! $CURIP has been modified in the last hour."
        # Send an email
	echo "Don't worry, I'm sending you an email with your new IP.."
        echo "Jean, your new IP is $NEWIP" | mail -s "ATTENTION: Your IP has changed" jeanelie.jg@gmail.com
	echo "Updating your IP on record on our end.."
	echo "$NEWIP" > ~/Scripts/myip.txt
	echo "All done!"
fi
