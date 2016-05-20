#!/bin/bash
#Test for arguments
if [ "$#" -ne 1 ]; then
  echo "Usage $0 <RIVENDELL_USERNAME>"
  exit 1
fi

USER=$1

#Install QT3
echo Installing QT3.3.8b...
sleep 1
#Install Build dependencies
apt -y install build-essential libx11-dev libxext-dev

#Get QT3 from source
wget http://download.qt.io/archive/qt/3/qt-x11-free-3.3.8b.tar.gz
tar -zxvf qt-x11-free-3.3.8b.tar.gz
rm qt-x11-free-3.3.8b.tar.gz
mv qt-x11-free-3.3.8b /usr/local/qt3
cd /usr/local/qt3

#Apply include stddef patches
patch src/tools/qmap.h /home/$USER/install/qt3/qmap.h.patch
patch src/tools/qvaluelist.h /home/$USER/install/qt3/qvaluelist.h.patch

#Build QT3
#Inform user they will have to type yes on the license
echo 
echo You will have to type yes to accept the QT3 license
read -p "Press [Enter] to continue or Ctrl + C to quit"
./configure
make
make install
echo

#Add paths to shell profile (not sure how this works with sudo)
echo Adding QT Paths to environment...
echo
echo
tQTDIR=/usr/local/qt3
tPATH=$tQTDIR/bin:$PATH
tMANPATH=$tQTDIR/doc/man:$MANPATH
tLD_LIBRARY_PATH=$tQTDIR/lib:$LD_LIBRARY_PATH

echo "PATH=$tPATH" > /etc/environment
echo "QTDIR=$tQTDIR" >> /etc/environment
echo "MANPATH=$tMANPATH" >> /etc/environment
echo "LD_LIBRARY_PATH=$tLD_LIBRARY_PATH" >> /etc/environment

#Export them so we don't have to logout (not sure how this works with sudo)
export QTDIR="$tQTDIR"
export PATH="$tPATH"
export MANPATH="$tMANPATH"
export LD_LIBRARY_PATH="$tLD_LIBRARY_PATH"
echo
echo

#Build the QT3 MySQL Driver
echo Building QT3 MySQL Driver
sleep 5
echo

#Install dependencies
apt -y install libmysqlclient-dev

#Build it
cd plugins/src/sqldrivers/mysql
qmake -o Makefile "INCLUDEPATH+=/usr/include/mysql/" mysql.pro
make install
echo
echo Done
