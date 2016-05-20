#!/bin/bash
### CONFIG CHANGE HERE ###
RIVHTTP=http://www.rivendellaudio.org/ftpdocs/rivendell/
#Make sure you use the tar.gz file not the zip
RIVSRC=rivendell-2.13.0.tar.gz
### DONT TOUCH BELOW HERE ###

#Test for arguments
if [ "$#" -ne 1 ]; then
  echo "Usage $0 <RIVENDELL_USERNAME>"
  exit 1
fi

USER=$1

#Add user to groups
adduser $USER audio
addgroup rivendell
adduser $USER rivendell

#Add Rivendell dependencies
echo Installing Rivendell dependencies...
sleep 1
echo
echo
#Install normal dependencies minus libqt3-mt-mysql and qt3-dev-tools (deprecated)
apt -y install libcdparanoia-dev libflac++-dev libsamplerate0-dev libid3tag0-dev libid3-3.8.3-dev libcurl4-gnutls-dev libsndfile-dev libpam0g-dev libsoundtouch1-dev libasound2-dev libtwolame-dev libmp3lame-dev libmp4v2-dev libfaad-dev libmad0-dev libjack-jackd2-dev libice-dev libsm-dev libxt-dev libxi-dev libmysqlclient-dev
echo
echo
echo Done

#Get Rivendell source
echo Downloading Rivendell Source...
echo
echo
wget $RIVHTTP$RIVSRC
tar -zxvf $RIVSRC
rm $RIVSRC
cd ${RIVSRC%.tar.gz}
echo
echo

#Patch the create DB bug (Github issue #121)
#@see https://github.com/ElvishArtisan/rivendell/issues/121
patch rdadmin/createdb.cpp /home/$USER/install/rivendell/createdb.cpp.patch
#Patch the create user DB bug (Github issue #123)
#@see https://github.com/ElvishArtisan/rivendell/issues/123
patch rdadmin/opendb.cpp /home/$USER/install/rivendell/opendb.cpp.patch
#Patch opendb.cpp to also set the global group by mode for mysql
#@see http://github.com/ElvishArtisan/rivendell/issues/125
patch rdadmin/opendb.cpp /home/$USER/install/rivendell/opendb.cpp.mysql-group.patch

echo
echo

#Re-export the QT directories because sudo wipes them (needed to build Riv)
echo Adding QT Paths to environment...
echo
echo
tQTDIR=/usr/local/qt3
tPATH=$tQTDIR/bin:$PATH
tMANPATH=$tQTDIR/doc/man:$MANPATH
tLD_LIBRARY_PATH=$tQTDIR/lib:$LD_LIBRARY_PATH
export QTDIR="$tQTDIR"
export PATH="$tPATH"
export MANPATH="$tMANPATH"
export LD_LIBRARY_PATH="$tLD_LIBRARY_PATH"
echo
echo

#Build Rivendell
echo Building Rivendell...
echo
sleep 1
./configure --libexecdir=/usr/local/libexec
echo 
echo "Please check that Rivendell has support for what you need"
echo "Everything except for HPI Audioscience support should say Yes"
read -p "Press [Enter] to continue or Ctrl + C to quit"
echo
echo
make
make install

#Remove the Rivendell init.d script (it doesn't create var run etc properly)
update-rc.d -f rivendell remove
rm /etc/init.d/rivendell

#Patch out the audio store from rd.conf-sample otherwise it gets confused
#because the store is empty and won't use /var/snd
patch conf/rd.conf-sample /home/$USER/install/rivendell/rd.conf-sample.patch

#Change the audio owner in rd.conf to the given user
sed -i 's/AudioOwner=rivendell/AudioOwner=$USER/g' conf/rd.conf-sample 

#Copy rd.conf to /etc
cp conf/rd.conf-sample /etc/rd.conf

#Install Rivendell Server Components
echo Installing Rivendell server components...
echo
echo
echo "You will have to set your MySQL password in this next step"
echo "Make a note of it, you will need it for rdadmin at the end"
echo
read -p "Press [Enter] to continue or Ctrl + C to quit"

#Install Apache and MySQL
apt -y install apache2 mysql-server
echo
echo

#Add Rivendell to Apache Config
echo Adding Rivendell Config to Apache...

#Patch Rivendell Apache config to remove old allow from directives
#Need to use Require granted since Apache 2.4
#@see http://httpd.apache.org/docs/2.4/howto/access.html
#@see https://github.com/ElvishArtisan/rivendell/issues/124
patch /home/$USER/install/rivendell-2.13.0/conf/rd-bin.conf /home/$USER/install/rivendell/rd-bin.conf.patch

#Copy Rivendell web config to apache and enable
cp /home/$USER/install/rivendell-2.13.0/conf/rd-bin.conf /etc/apache2/sites-available/

#Enable rd-bin and reload
a2ensite rd-bin
service apache2 reload

#Enable cgi mod and restart Apache2
a2enmod cgi
service apache2 restart

#Clean up Rivendell source folder
rm -r /home/$USER/install/rivendell-2.13.0

#MySQL Config
#Amend MySQL to default to MyISAM (Required by Rivendell)
patch /etc/mysql/mysql.conf.d/mysqld.cnf /home/$USER/install/mysql/mysqld.cnf.patch

#Reload MySQL
echo Restarting MySQL to apply changes...
service mysql restart

#Rivendell /var/snd
echo Creating /var/snd...
echo
mkdir -p /var/snd
chown $USER:rivendell /var/snd
chmod ug+rwx /var/snd
echo
echo

#Rivendell Init Script (daemons and /var/run/rivendell)
echo Adding Rivendell SystemD service...
cp /home/$USER/install/systemd/caed.service /etc/systemd/system/
cp /home/$USER/install/systemd/ripcd.service /etc/systemd/system/
cp /home/$USER/install/systemd/rdcatchd.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable caed.service
systemctl enable ripcd.service
systemctl enable rdcatchd.service
echo
echo
echo All Done, after reboot you have to run the following two commands:
echo -e '\t'sudo rdalsaconfig
echo -e '\t'rdadmin
echo
echo You will probably get the message "Unable to start daemons"
echo this is because caed couldn't start because the Rivendell database wasn't
echo created.
echo
echo Start the rivendell services manually or reboot at this stage
echo -e '\t'sudo service caed start
echo -e '\t'sudo service ripcd start
echo -e '\t'sudo service rdcatchd start
echo
read -p "Press [Enter] to reboot or Ctrl + C to quit"
reboot
