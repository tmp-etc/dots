#!/bin/bash

MYIP='90.191.166.32'

ufw enable
ufw allow from $MYIP to any port 22 proto tcp
apt-get update 
apt-get install -y ranger caca-utils highlight atool w3m poppler-utils mediainfo neovim
adduser aaa
echo "alias xforce='mkdir blabla && tar -x -C blabla -f'" >> /home/aaa/.bashrc
echo "export EDITOR=nvim" >> /home/aaa/.bashrc
su -c "ranger --copy-config=all" aaa
sed -i -e 's/^set viewmode miller/set viewmode multipane/g' /home/aaa/.config/ranger/rc.conf
