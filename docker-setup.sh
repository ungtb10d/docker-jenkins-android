#!/bin/sh
set -e

JUSER="jenkins"

DOCKER_GID=$(ls -aln /var/run/docker.sock  | awk '{print $4}')

# TODO: can we also download the static docker client binary for the 
#       docker server version?

if ! getent group $DOCKER_GID; then
	echo creating docker group $DOCKER_GID
	addgroup -g $DOCKER_GID docker
fi

if ! getent group $GID; then
	echo creating $JUSER group $GID
	addgroup -g $GID $JUSER
fi

if ! getent passwd $JUSER; then
	echo useradd -N --gid $GID -u $UID $JUSER
	useradd -N -g $GID -u $UID $JUSER
fi

DOCKER_GROUP=$(ls -al /var/run/docker.sock  | awk '{print $4}')
if ! id -nG "$JUSER" | grep -qw "$DOCKER_GROUP"; then
	adduser $JUSER $DOCKER_GROUP
fi

# TODO: work out why this happens intermittently
chown -R $JUSER:$JUSER /var/jenkins_home/

exec su $JUSER -c "/sbin/tini -- /usr/local/bin/jenkins.sh"
