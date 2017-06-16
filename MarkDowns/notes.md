#### molecule test options how wether or not to destroy docker instance

```shell
molecule test --destroy [always,never,passing]
```

----
#### attach to a docker instance runing in background
```shell
docker exec -i -t $ID /bin/bash
```
#### save docker image
```shell
docker save -o myimg.tar
```
#### export docker image
```shell
docker export -o myimg.tar
```

#### import docker image with tag
```shell
docker import myimg.tar -c "ENTRYPOINT docker-entrypoint.sh" myimg:v0.5.6
```

#### how to exclude files when creating archive
```shell
tar -czf archive_file.tar.gz target --exclude="*.zip" --exclude="*.war"
```

#### mount windows shares on CentOS 7
```shell
mount.cifs --verbose -o username='alan_cheng',\
password='yourPass',sec=ntlm \
\\\\epbyminw1383.minsk.epam.com\\install_VEL /mnt
```

#### list samba users in its own database
```shell
pdbedit -L
```

#### show all git commits in master that aren’t in experiment 

```shell
git log experiment..master
```

#### git checkout a single file (core.py) from another branch (e.g dev)
```shell
git checkout dev -- core.py
```

#### start configure sound device GUI
```shell
pavucontrol
```
#### add static route via IP command
```shell
sudo ip route add 192.168.0.0/24 via 10.22.17.55 dev eno1
```

#### change last commit msg in git
```shell
git commit --amend
git push --force ## if previous commit msg has been pushed out
```

#### reconfigure lxd network (lxd init has been executed before)
```shell
sudo dpkg-reconfigure -p medium lxd
```

#### configure lxd to use physical network (bridge)
```shell
lxc profile device set default eth0 parent eno1
lxc profile device set default eth0 nictype macvlan
```

#### manage virtualbox on CLI
```shell
vboxmanage list vms
vboxmanage import vmname.ova
vboxmanage startvm vmname --type headless
VBoxManage extpack install name.extpack
vboxmanage guestcontrol "<vbox_name>" updateadditions  --source /usr/share/virtualbox/VBoxGuestAdditions.iso --verbose
vboxmanage guestproperty get "vm-name" "/VirtualBox/GuestInfo/Net/0/V4/IP"
vboxmanage showvminfo WIN10_64

```

#### reset mysql root password
```mysql
#For MySQL 5.7.5 and older as well as MariaDB 10.1.20 and older, use:
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('new_password');

#For MySQL 5.7.6 and newer as well as MariaDB 10.1.20 and newer, use the following command.
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';

#or a more traditional method
UPDATE mysql.user SET authentication_string = PASSWORD('new_password') WHERE User = 'root' AND Host = 'localhost';
```
#### configure system env for JAVA_HOME in command line, on Windows
```powershell
setx /m JAVA_HOME "C:\Program Files\Java\jdk1.8.0_131"
```

#### run one time scheduled task with at
```shell
at -f ~/myscript.sh 8PM

# or input command from stdin
at 10PM
at> echo "this is just an example"
at> ls -l ~/Documents
^D

# use atq to view task queues
atq

# use atrm to delete task by ID
atrm 4
```
#### lsof frequently used arguments
```shell
#Which processes have an open socket on a TCP port
lsof -i :8080

# Which processes have an open TCP socket to www.google.com
lsof -iTCP@www.google.com:80

# Show connec­tions to a host
lsof -i@192.16­8.1.5

# Find ports that are being listened to
lsof -i| grep LISTEN

# Which processes are accessing the Mysql socket?
lsof /var/run/mysql/mysql.sock

# Which processes have the nginx binary open
lsof /usr/sbin/nginx

# find files open by user
lsof -u $USER

# find files open by proccess id
lsof -p $PID

# get list of processes in use by command
lsof -t -c <co­mma­nd>

# Open files within a directory
lsof +D /path

# By program name
lsof -c apache

# AND'ing selection conditions
lsof -u www-data -c apache

# NFS use
lsof -N 

# UNIX domain socket use
lsof -U 
```

#### bash variable substitution rules
```shell

# '${var#Pattern}' Remove from $var the 'shortest' part of $Pattern that matches the front end of $var.

# '${var##Pattern}' Remove from $var the 'longest' part of $Pattern that matches the front end of $var.
---

# '${var%Pattern}' Remove from $var the shortest part of $Pattern that matches the 'back' end of $var.


# '${var%%Pattern}' Remove from $var the longest part of $Pattern that matches the 'back' end of $var.


#  '*' is a wildcard

var=abcd-1234-defg
echo ${var#*-*}  # result: 1234-defg
echo ${var#*-}   # result: 1234-defg  '*' can mean nothing

# ${var:pos}
# Variable var expanded, starting from offset pos.

# ${var:pos:len}
# Expansion to a max of len characters of variable var, from offset pos. 
path_name="/home/bozo/ideas/thoughts.for.today"
t=${path_name:11}  ## ideas/thoughts.for.today
echo "$path_name, with first 11 chars stripped off = $t"

t=${path_name:11:5}  ## ideas
echo "$path_name, with first 11 chars stripped off, length 5 = $t"
# ${var/Pattern/Replacement}
# First match of Pattern, within var replaced with Replacement.

# If Replacement is omitted, then the first match of Pattern is replaced by nothing, that is, deleted.

# ${var//Pattern/Replacement}
# Global replacement. All matches of Pattern, within var replaced with Replacement.

# As above, if Replacement is omitted, then all occurrences of Pattern are replaced by nothing, that is, deleted.

# ${var/#Pattern/Replacement}
# If prefix of var matches Pattern, then substitute Replacement for Pattern.

# ${var/%Pattern/Replacement}
# If suffix of var matches Pattern, then substitute Replacement for Pattern.

# ${!varprefix*}, ${!varprefix@}
# “Matches names of all previously declared variables beginning with varprefix.”

xyz23=whatever
xyz24=

a=${!xyz*}         #  Expands to *names* of declared variables
# ^ ^   ^           + beginning with "xyz".
echo "a = $a"      #  a = xyz23 xyz24
a=${!xyz@}         #  Same as above.
echo "a = $a"      #  a = xyz23 xyz24

echo "---"

abc23=something_else
b=${!abc*}
echo "b = $b"      #  b = abc23
c=${!b}            #  Now, the more familiar type of indirect reference.
echo $c            #  something_else
```

