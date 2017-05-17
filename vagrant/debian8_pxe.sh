#!/bin/bash
tftp_config_file='/etc/default/tftpd-hpa'
dhcpd_conf='/etc/dhcp/dhcpd.conf'

## download
wget -O /tmp/erpxe.tar.gz http://sourceforge.net/projects/erpxe/files/latest/download?source=files
cd /
tar zxf /tmp/erpxe.tar.gz

apt-get install -y tftpd-hpa apache2 nfs-kernel-server samba isc-dhcp-server
update-rc.d tftpd-hpa defaults
update-rc.d apache2 defaults
update-rc.d nfs-kernel-server defaults
update-rc.d samba defaults
restorecon -r /tftpboot

tftp_config='TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot/"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-m /tftpboot/erpxe.remap -vvvvv -s"'
echo "$tftp_config" > $tftp_config_file

## apache2 configuration
cp /tftpboot/bin/setup/erpxe-httpd.conf /etc/apache2/conf-available/

## NFS config
cat /tftpboot/bin/setup/erpxe-exports > /etc/exports

## Samba config
cat /tftpboot/bin/setup/erpxe-smb.conf > /etc/samba/smb.conf

## security=share deprecated in new version of samba
sed -i 's/security = share/security = user/' /etc/samba/smb.conf
sed -i '/security =  user/i \map to guest = bad user\n' /etc/samba/smb.conf

useradd --no-create-home -s /dev/null erpxe
(echo mypass;echo mypass)|smbpasswd -s -a erpxe
(echo mypass;echo mypass)|smbpasswd -s -a root

## DHCPD config
dhcpd_config='
ddns-update-style none;
option domain-name "my.internal";
option domain-name-servers 8.8.8.8, 8.8.4.4;
default-lease-time 600;
max-lease-time 7200;
log-facility local7;
subnet 10.0.0.0 netmask 255.255.255.0 {
  range 10.0.0.26 10.0.0.130;
  option domain-name-servers 8.8.8.8;
  option domain-name "my.internal";
  option routers 10.0.0.1;
  option broadcast-address 10.0.0.255;
  default-lease-time 600;
  max-lease-time 7200;
  next-server 10.0.0.1;
  filename "pxelinux.0"; 
}
'
echo "$dhcpd_config" > $dhcpd_conf

## when used with vagrant/virtualbox and network is set 
## to public in Vagrantfile, vagrant will create 2nd NIC
## and it should be refered to as eth1 in Debian 8
interface_config='
auto eth1
iface eth1 inet static
  address 10.0.0.1
  netmask 255.255.255.0
'
echo "$interface_config" >> /etc/network/interfaces

systemctl disable networking
systemctl stop networking

ip addr add 10.0.0.1/24 dev eth1
## enable services
for i in smbd tftpd-hpa apache2 isc-dhcp-server nfs-kernel-server
do
	systemctl start $i
	systemctl enable $i
done
