#!/bin/bash

# Exit functions
function stop_server() {
        echo "Stopping Server...."
	sudo -u steam tmux send-keys -t 0 "save" Enter "quit" Enter 
} 

# Trap 
trap 'stop_server' TERM

# Set the user ID and group id
usermod -u ${PUID} steam
groupmod -g ${PGID} steam 

# Set the ownership of /data to the steam user
chown -Rf steam:steam /home/steam 

# Clear console log
echo -n > /home/steam/Zomboid/server-console.txt

# Install server
sudo -u steam /usr/games/steamcmd "+force_install_dir /home/steam/pzserver +login anonymous +app_update ${STEAM_APP} validate +quit"

# Launch server 
sudo -u steam tmux new-session -d /home/steam/pzserver/start-server.sh -servername ${SERVER_NAME} ${SERVER_ADDITIONAL_PARAMS}

# Tail console log to output
tail -f -n +1 /home/steam/Zomboid/server-console.txt & 

# Wait at least 30 seconds
sleep 30

# Loop in sleep - we have to do this so that the traps work
while [ "$(pgrep ProjectZomboid | wc -l)" -gt 0 ]; do
	sleep 1
done 

# Exit
exit 0 
