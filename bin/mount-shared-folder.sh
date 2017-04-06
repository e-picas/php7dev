#!/usr/bin/env bash
if [ "$1" == '-h' ]||[ "$1" == '--help' ]||[ "$1" == 'help' ]; then
    >&2 cat <<EOT

usage:  $0 [arg1] [arg2]

arguments (all optional):
        [arg1]: SHAREDNAME defaults to 'php-scripts-local'
        [arg2]: TARGETPATH defaults to '/var/www/default/php-scripts-local/'

  i.e.  $0
        $0 my-custom-shared-name
        $0 my-custom-shared-name /my/custom/host/path

EOT
    exit 0
fi
SHAREDNAME="${1:-php-scripts-local}"
TARGETPATH="${2:-/var/www/default/php-scripts-local}"
echo "sudo mkdir -p $TARGETPATH" && \
sudo mkdir -p $TARGETPATH && \
echo "sudo mount -t vboxsf -o uid=1000,gid=1000 $SHAREDNAME $TARGETPATH" && \
sudo mount -t vboxsf -o uid=1000,gid=1000 $SHAREDNAME $TARGETPATH ;
