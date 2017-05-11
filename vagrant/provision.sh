#!/bin/bash
USERNAME=acheng
encrpt_pwd='$6$PaKpz7aa$gYHGvIPcSamv8ji4NuOZ9dvjgQQiT27a6ii1UPYPlYjVYQIN2qu01PSuXP/3n7YwMMvq5k/keok2n57gY66SL1'
id -u $USERNAME 
if [[ ! $? -eq 0 ]];then
	useradd -m -d /home/$USERNAME $USERNAME
	usermod -p "$encrypt_pwd" $USERNAME
fi

[[ -f /etc/sudoers ]] && cp /etc/sudoers /var/tmp/
distro=$(lsb_release -i|cut -d":" -f2|sed 's/[ |\t]*//g')
case $distro in
	CentOS)
		usermod -aG wheel $USERNAME
		sed -i '/^%wheel/s/\tALL$/\tNOPASSWD: ALL/' /etc/sudoers
		;;
	Ubuntu)
		usermod -aG sudo $USERNAME
		usermod -s /bin/bash $USERNAME
		sed -i '/^%sudo/s/\tALL$/\tNOPASSWD: ALL/' /etc/sudoers
		;;
	*)
		echo "unknown distro. sudo will not work"
		;;

esac
[[ -d /home/$USERNAME/.ssh ]] || mkdir /home/$USERNAME/.ssh
echo "
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeuRFVqVd6xiAzcqh4AhsHZRtlchKG9wvTIJ4XjkeI9dmu1WgYQqCe7RmfPnj4l80i7nWORUS6GdS54uyEoih2ydNMPm0/TDsapZW2OUGL3J2+zIfTOHmTb6dTOKlzFnpvgm7JMzPvh6DbAMCVCf7bYRUSXSij3zhGy3K4H1PfA4WJAqkosSvdcDbX06lIZhXmfs9S7ZVLakY8UawPKXQkGY0FCCPXRsVCDcOaJrdyXnsIXYQCm3VWte2n2zQUTgI+6OZaejVB7QyKt71SAwikLsaIBWHeIHsvfe1ovGZpULZCMxdoFQC5duK1aQVSABEYaB67Z8fGyLvToaTZ7E5t acheng@epcnszxw0150" >> /home/$USERNAME/.ssh/authorized_keys
chmod 400  /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/${USERNAME}

## check sudoer, in case any syntax error
visudo -c -q
if [[ ! $? -eq 0 ]];then
	cp /var/tmp/sudoers /etc/
fi

## display IP
ip addr s | grep brd | grep inet
