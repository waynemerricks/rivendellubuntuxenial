#!/bin/bash
#This runs through the entire Rivendell install and then reboots
#It needs your Rivendell users login name in order to work correctly

#Test for arguments
if [ "$#" -ne 1 ]; then
  echo "Usage $0 <RIVENDELL_USERNAME>"
  exit 1
fi

#Test for sudo
if [ "$(id -u)" != "0" ]; then
  echo "Please run sudo $0"
  exit 1
fi

echo Installing Rivendell 2.13.0 From Source under Ubuntu 16.04
read -p "Press [Enter] to continue or Ctrl + C to quit"

#Check files exist
#Shell scripts
#XFCE
if [ ! -f ./002.install_xfce.sh ]; then
  echo 002.install_xfce.sh is not found, aborting
  exit 1
fi

#QT3
if [ ! -f ./003.install_qt3.sh ]; then
  echo 003.install_qt3.sh is not found, aborting
  exit 1
fi

#RIVENDELL
if [ ! -f ./004.install_rivendell.sh ]; then
  echo 004.install_rivendell.sh is not found, aborting
  exit 1
fi

#Patch Files
#QT3
#QMAP.H
if [ ! -f ./qt3/qmap.h.patch ]; then
  echo qt3/qmap.h.patch is not found, aborting
  exit 1
fi

#QVALUELIST.H
if [ ! -f ./qt3/qvaluelist.h.patch ]; then
  echo qt3/qvaluelist.h.patch is not found, aborting
  exit 1
fi

#RIVENDELL
#CREATEDB.CPP
if [ ! -f ./rivendell/createdb.cpp.patch ]; then
  echo rivendell/createdb.cpp.patch is not found, aborting
  exit 1
fi

#CREATEDB.CPP Instance Patch
if [ ! -f ./rivendell/createdb.cpp-instance.patch ]; then
  echo rivendell/createdb.cpp-instance.patch is not found, aborting
  exit 1
fi

#OPENDB.CPP
if [ ! -f ./rivendell/opendb.cpp.patch ]; then
  echo rivendell/opendb.cpp.patch is not found, aborting
  exit 1
fi

#RD.CONF
if [ ! -f ./rivendell/rd.conf-sample.patch ]; then
  echo rivendell/rd.conf-sample.patch is not found, aborting
  exit 1
fi

#RD-BIN.CONF
if [ ! -f ./rivendell/rd-bin.conf.patch ]; then
  echo rivendell/rd-bin.conf.patch is not found, aborting
  exit 1
fi

#MYSQL
#MYSQLD.CNF
if [ ! -f ./mysql/mysqld.cnf.patch ]; then
  echo mysql/mysqld.cnf.patch is not found, aborting
  exit 1
fi

#MYSQLD.CNF - group mode
if [ ! -f ./mysql/mysqld.cnf.group-mode.patch ]; then
  echo mysql/mysqld.cnf.group-mode.patch is not found, aborting
  exit 1
fi

#SYSTEMD SERVICES
#CAED.SERVICE
if [ ! -f ./systemd/caed.service ]; then
  echo systemd/caed.service is not found, aborting
  exit 1
fi

#RIPCD.SERVICE
if [ ! -f ./systemd/ripcd.service ]; then
  echo systemd/ripcd.service is not found, aborting
  exit 1
fi

#CAED.SERVICE
if [ ! -f ./systemd/rdcatchd.service ]; then
  echo systemd/rdcatchd.service is not found, aborting
  exit 1
fi

#All files found continue
echo All files are in order, installing...
sleep 1
#Install Desktop
./002.install_xfce.sh

#Install QT3
./003.install_qt3.sh $1

#Install Rivendell
./004.install_rivendell.sh $1
