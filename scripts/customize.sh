#!/bin/sh
# Add any extra stuff you might need here.

# add vagrant user to group vboxsf
usermod -a -G vboxsf vagrant ;
# add root user to groups vboxsf & www-data
usermod -a -G vboxsf root ;
usermod -a -G www-data root ;

# have a funny command line for root
cat /home/vagrant/.bashrc > /root/.bashrc
cat /home/vagrant/.bash_aliases > /root/.bash_aliases

# build and enable PHP 7.0
makephp 70 ;
newphp 70 ;

# update all & enable apache
apt-get update ;
apt-get upgrade ;
update-rc.d -f nginx remove ;
update-rc.d -f apache2 enable ;

# copy local PHP files
cp -r /home/vagrant/php-scripts /var/www/default/php-scripts/ ;
cp /home/vagrant/php-scripts/mount-shared-folder.sh /mount-shared-folder.sh ;
chmod a+x /mount-shared-folder.sh ;

# enable Apache and set our scripts as default directory
rm -f /var/www/default/index.* ;
rm -f /var/www/default/50x.html ;
chown -R vagrant:www-data /var/www/default/ ;
service nginx stop ;
#sed -i 's#/var/www/default#/var/www/php-scripts#' /etc/apache2/sites-available/000-default.conf ;
apachectl start ;
a2enmod autoindex ;

# enable FR keyboard
cat > /etc/default/keyboard <<EOT
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="fr"
XKBVARIANT=""
XKBOPTIONS="grp:alt_shift_toggle"

BACKSPACE="guess"

EOT

# welcome message
cat > /etc/motd <<EOT
----
Bienvenue sur ce serveur PHP de démonstration

Cette machine virtuelle embarque:
    - un système Debian 8.5
    - un serveur web Apache 2.4
    - un compilateur PHP 7.0
Les sources du serveur web sont disponibles dans:
    /var/www/default/

Pour plus d'infos, voyez la page <https://github.com/e-picas/php7dev>
----

EOT

## Optimize VM for export
# <https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm>

# share folder (on host)
#VBoxManage sharedfolder add php7-server --name php-scripts-local --hostpath /path/to/php-initiation/
# share folder (on guest)
#vagrant@php7-server$ sudo mount -t vboxsf -o uid=$UID,gid=$GID php-scripts-local /var/www/default/php-scripts-local/

# switch to VDI disk (on host)
#VBoxManage clonehd --format VDI /path/to/php7-server/box-disk1.vmdk /path/to/php7-server/php7-server-disk.vdi

# decrease HD space (on guest)
#dd if=/dev/zero of=/emptyfile bs=1M && rm -rf /emptyfile ;

# decrease HD space (on host)
#VBoxManage modifyhd /path/to/php7-server/php7-server-disk.vdi --compact
