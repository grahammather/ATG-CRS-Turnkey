#!/bin/bash
# this script runs once on provision
# at the end of it, you've got a database ready for connections from ATG

# verify centos release
if [ -f /etc/centos-release ]; then
	echo "Converting to Oracle Linux"
	cat /etc/centos-release
else
	echo "Already converted to Oracle Linux"
fi

# fastestmirror plugin causes problems. just disable plugins
sed -i.bak 's/plugins=1/plugins=0/g' /etc/yum.conf

# silent install means assume yes for everything
if  ! grep -qe "^assumeyes" "/etc/yum.conf"; then
	echo "assumeyes=1" >> /etc/yum.conf
else
	sed -i.bak 's/assumeyes=0/assumeyes=1/g' /etc/yum.conf
fi

# convert into Oracle Linux 6, if we haven't already
if [ ! -f /etc/oracle-release ]; then
	curl -O https://linux.oracle.com/switch/centos2ol.sh
	sh centos2ol.sh; echo success
fi

# verify oracle release
cat /etc/oracle-release

# upgrade yum
yum upgrade -y

# install tools
yum install -y unzip

# oracle prerequisites
yum install -y oracle-rdbms-server-11gR2-preinstall

# create directories
mkdir -p /opt/oracle /opt/oraInventory /opt/datafile \
 && chown oracle:oinstall -R /opt

if  ! grep -qe "^export ORACLE_BASE=" "/home/oracle/.bash_profile"; then
	echo "export ORACLE_BASE=/opt/oracle" >> /home/oracle/.bash_profile \
 		&& echo "export ORACLE_HOME=/opt/oracle/product/11.2.0.4/dbhome_1" >> /home/oracle/.bash_profile \
 		&& echo "export ORACLE_SID=orcl" >> /home/oracle/.bash_profile \
 		&& echo "export PATH=\$PATH:\$ORACLE_HOME/bin" >> /home/oracle/.bash_profile
fi