#!/bin/bash

__create_user() {
# Create a user to SSH into as.
#USER=`echo ${SSH_USER}`
USER=`echo ${SSH_USER}`
SSH_USERPASS=`echo ${SSH_PASS}`

useradd -u 1001 ${USER} 

echo -e "$SSH_USERPASS\n$SSH_USERPASS" | (passwd --stdin ${USER})
echo ssh ${USER} password: $SSH_USERPASS
}

# Call all functions
__create_user