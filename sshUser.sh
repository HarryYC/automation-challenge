#!/bin/bash
if [ "$#" -ne 4 ] || ! [ -f "$1" ] || ! [ -f "$2" ] || [ $3 != "grant" -a $3 != "revoke" ]; then
  echo "Usage: $0 SERVERLIST USERLIST grant/revoke"
  echo "Example: $0 server.txt user.txt grant"
  exit 1
fi

SERVERLIST="$1"
USERLIST="$2"
LOGPATH="/var/log/sshUser.log"
echo -e "$(date)\n" >> ${LOGPATH}

#loop each server in SERVERLIST
while IFS=" " read -r IP LOGINNAME LOGINPW
do
  SCRIPT=""
  echo -e "\n$IP" >> ${LOGPATH}
  #loop each user in USERLIST
  while IFS=" " read -r USERNAME USERPW
  do
    if [ "$3" = "grant" ]; then
      #add user
      SCRIPT="echo "${LOGINPW}" | sudo -S useradd \
      -g users \
      -d /home/${USERNAME} \
      -s /bin/bash \
      -p '$(echo "${USERPW}" | openssl passwd -1 -stdin)' \
      ${USERNAME};"${SCRIPT}
    else
      #delete user
      SCRIPT="echo "${LOGINPW}" | sudo -S userdel ${USERNAME};"${SCRIPT}
    fi
  done < "$USERLIST"
  #execute the command on remote server and save the log file

  sshpass -p "${LOGINPW}" ssh -o StrictHostKeyChecking=no -l ${LOGINNAME} ${IP} "${SCRIPT}" < /dev/null\
  >>$LOGPATH 2>&1 || true
done < "$SERVERLIST"

echo -e "\n-----------DONE--------------" >> ${LOGPATH}



#the StrictHostKeyChecking option  disable the host key check 
#and automatically add the host key to the list of known hosts
