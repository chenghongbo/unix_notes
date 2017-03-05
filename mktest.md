>## 1. Install vagrant


**Answer:**

one way to install vagrant is by downloading latest version from https://www.vagrantup.com/downloads.html.

For an 64bit CentOS, download from:https://releases.hashicorp.com/vagrant/1.9.1/vagrant_1.9.1_x86_64.rpm

then run: 

```shell
yum localinstall vagrant_1.9.1_x86_64.rpm
```
also, we need to install one of the supported virtual machine provider, such as virtualbox, to get vagrant functioning.


---

> ## 3. Using vagrant file create linux-based virtual machine using any modern linux os (latest centos will be ok)


**Answer:**

create a Vagrantfile with the following content and then run '**vagrant up**' command:

```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = "centos7"
  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end
end
```
---

>>>
##  4. Setup the following system on vm:
* Create git repository

*  Create  java helloworld application.
* Add source code to repository
* Create script to install Jenkins and apache httpd  - bash or chef or any other - Jenkins should be installed via script, such that
     - Configure Jenkins and Apache for direct access to Jenkins dashboard by HTTP. URL should have form http://1.1.1.1/jenkins where 1.1.1.1 is the ip address of your vm
     - Jenkins should fetch configs from git repository

* Create ant script to compile the code and pack it as jar file

* Setup Jenkins to compile the code - create compilation job

     - All scripts and jenkins jobs must be in git repository

* Create "releases" folder on vm instance and configure Apache for direct access to this folder content by HTTP. URL should have form http://1.1.1.1/releases

* Jenkins should place build result (jar) to this folder
 
**Deliverables:**
- script for Jenkins+apache+releases folder setup
- git repository with:
  - java helloworld app
  - ant script
  - jenkins configuration

>>>

**Answer:**

# deliverable one:  bash script for Jenkins+apache+releases folder setup

This script  install and configure apache/jenkins, which can be used as vagrant shell provisioner:
This script does the following:

* install jenkins stable repo
* install Jenkins software, and java openJDK and apache2
* edit httpd.conf as a reverse proxy for Jenkins, and create an alias for /release located in /proj/release, where we will put jar files created by Jenkins build job
* disable SELinux
* create /jenkins_home folder the copy all default Jenkins files from /var/lib/Jenkins there
* edit /etc/sysconfig/jenkins to tell Jenkins to use new home dir and use /jenkins as prefix


```shell
#!/usr/bin/env bash

## install jenkins offical repo and then install jenkins stable from there
## also install java jdk
sudo yum install -y wget git

sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

sudo yum install -y jenkins java-1.8.0-openjdk java-1.8.0-openjdk-devel httpd

## configure apache to reverse proxy for jenkins, which will be running on port 8080

## use sed to add below mod_proxy and release folder alias settings to httpd.conf, contained in $config_for_apache

config_for_apache='
ProxyPass         /jenkins  http://localhost:8080/jenkins       nocanon\n
ProxyPassReverse  /jenkins  http://localhost:8080/jenkins\n
ProxyRequests     Off\n
AllowEncodedSlashes NoDecode\n
ProxyPreserveHost on\n

<Proxy http://localhost:8080/jenkins*>\n
   Order deny,allow\n
   Allow from all\n
</Proxy>\n
\n
## for serving /release as an alias, which is located under /proj/release\n
Alias /release /proj/release\n
<Directory "/proj/release">\n
Options +Indexes\n
AllowOverride None\n
Require all granted\n
</Directory>\n
'

config_for_apache=$(echo $config_for_apache | sed 's#/#\/#g')
sudo sed -i '/^#ServerName/a '"$config_for_apache" /etc/httpd/conf/httpd.conf


## edit Jenkins config /etc/sysconfig/jenkins (on redhat based distro) to work with reverse proxy

sudo echo 'JENKINS_ARGS="--prefix=/jenkins"' >> /etc/sysconfig/jenkins

## disable SELinux and then make it permnant
sudo setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/#' /etc/selinux/config


## create folder as Jenkins home directory and init it as a git repo

sudo mkdir /jenkins_home

sudo chown -R jenkins:jenkins /jenkins_home

sudo usermod -d /jenkins_home jenkins

## edit /etc/sysconfig/jenkins to use the new Jenkins home dir
sudo sed -i 's#^JENKINS_HOME="/var/lib/jenkins"#JENKINS_HOME="/jenkins_home"#g' /etc/sysconfig/jenkins

mkdir -p /proj/{release,src}
chown -R jenkins:jenkins /proj
chown -R jenkins:apache /proj/release


## enable and start jenkins and apache

for i in jenkins httpd
do
	sudo systemctl enable $i
	sudo systemctl start $i
done

```
# deliverable 2 - part 1: repo for java hello world app, ant build.xml file
This is done in a script, and it can be combined with the first one
This script does the following:

* install git
* create hello.java, the java hello world source code
* create build.xml for building hello.java using Ant
* init git repo in src folder, add hello.java and build.xml file to it
 all files will be put under /proj dir, /proj/src for source, /proj/release for the jar file

```shell
#!/usr/bin/env bash
sudo yum install -y git
cd /proj/src; git init

## java hello world file
cat > hello.java <<EOF
public class hello {
    public static void main( String[] args )
    {
        System.out.println( "Hello World" );
    }
}
EOF


## add ant build file, it will create jar file and put it in the /proj/release folder
cat > build.xml <<EOF
<project default="compile">
  <target name="compile">
    <javac srcdir="." />
  </target>

  <target name="jar" depends="compile">
    <jar destfile="/proj/release/hello.jar"
         basedir="."
         includes="**/*.class">
		 <manifest>
		    <attribute name="Main-Class" value="hello"/>
		</manifest>
         </jar>
  </target>

  <target name="run" depends="jar">
    <java classname="hello"
          classpath="hello.jar"
          fork="true"
          />
  </target>
</project>
EOF

git config --global user.email  "acheng@example.com"
git config --global user.name  "Alan Cheng"
chown jenkins:jenkins *
git add hello.java build.xml
git commit -m"initial commit for java helloworld"

```
# create Jenkins compile job to build the java hello world source code

192.168.0.108 is the IP for the VM running Jenkins and apache.

Here are the steps to configure Jenkins itself and then create the build job


* step 1:  go to http://192.168.0.108/jenkins, put in the password to unlock Jenkins, install all recommended plug-ins, 
and then create admin user

* step 2:  go to http://192.168.0.108/jenkins/configureTools/ to add Ant and have Jenkins auto install it from Apache website

* step 3: http://192.168.0.108/jenkins/view/All/newJob to create the build job, name it java_helloworld for this case

* step 4:  fill in details in build job details.

  - in "Source Code Management" section, select "git", and put  **file://localhost/proj/src ** as Repo URL, as this is a local git repo

  - in "Build" section, click "add build step" drop-down menu, then pick "Invoke Ant", then put in "ant" for  "Ant Version", 
which is what we named it  in step 2,  put "jar" for "Targets"

then we can go back to http://192.168.0.108/jenkins and trigger the build manually, 
it'll generate jar files for our Java hello world program.

# deliverable 2 - part 2: get jenkins config into a (local) git repo, via a periodical Jenkins job
  (SCM Sync configuration plugin seems doesn't work very well)
* step 1: create .gitignore file in /jenkins_home, the JENKINS_HOME diretory, to exclude files no need to backup, like the plugin/* folder
* step 2:  create a job with name "check_config_git", with the following configuration:
 - set build trigger to "Build periodically", with schedule set to ' H H(9-16)/2 * * 1-5', means once in every two hours slot between 9 AM and 5 PM every weekday
 - set 'add build step' to 'execute shell', and with 'command' set as following:

```shell
cd /jenkins_home
[ -d .git ] || git init
git add -A .
git commit -am "backup config on $(date)"
```
* click 'save' to save the job. and it'll automatically check all files into git repo
* we can backup the repo on a remote place if needed
