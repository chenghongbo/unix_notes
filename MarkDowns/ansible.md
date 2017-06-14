# Ansible Notes
### what is ansible
 	a configuration management application wirten in Python, the same category of Puppet, Chef
### why you want to use ansible
    no client application required (works over SSH)
	simple architecture
	easier to maintain
	use text file to store client hostnames (but could be an issue if thousands or more )
### setup
	--requires python 2.6/2.7, pip, bash shell (if running on BSD or non-linux platforms)
		some python packages
		 pip install paramiko PyYAML Jinja2 httplib2 six

	-- installation using source 
		git clone https://github.com/ansible/ansible.git --recursive
		cd ansible; source hacking/env-setup
		export ANSIBLE_INVENTORY=~/ansible_hosts (file to store client hostnames or groups)

	-- to update
			git pull --rebase
			git submodule update --init --recursive
            
### Issues:
	- requires SSH key setup before it can run commands on client (remotely)
		- can be worked around by setting ansible_ssh_pass variable, teperarily
	
	- doesn't work well when python is not located in /usr/bin/python
		- need to set ansible_python_interpreter variable for these hosts (clients)

### To test setup:
		echo "127.0.0.1" > ~/ansible_hosts
		ansible all -m ping
        

***
### Run Ad-hoc commands
	copy file, where "atlanta" could be a server name or group name in the inventory file
	- ansible atlanta -m copy -a "src=/etc/hosts dest=/tmp/hosts"
	- ansible hostname -m shell -a "echo var"
	- ansible webservers -m file -a "dest=/srv/foo/b.txt mode=600 owner=mdehaan group=mdehaan"
	- ansible webservers -m file -a "dest=/path/to/c state=absent"
	- ansible webservers -m yum -a "name=acme state=latest"
	- ansible all -m user -a "name=foo password=encrypted_password"
	- ansible webservers -m service -a "name=httpd state=started"
	- ansible webservers -m service -a "name=httpd state=restarted"

	- ansible all -B 1800 -P 60 -a "/usr/bin/long_running_operation --do-stuff"
	-- The above example says “run for 30 minutes max (-B: 30*60=1800), 
	--   poll for status (-P) every 60 seconds”.

	- ansible hostname -m setup
	-- list basic information about clients (facts)

### ansible roles
    - Tasks :
		contain the core logic, for example, they will have code specifications
		to install packages, start services, manage files, and so on. If we consider a
		role to be a movie, a task would be the protagonist.

    - Vars:
        and defaults provide data about your application/role, for example,
        which port your server should run on, the path for storing the application
        data, which user to run the service as, and so on. 

    - handlers: 
       like a function or method in OOP, handlers are actions that can be called (or notified, in ansible terms) when a certain event occur

        A handler would be called only once no matter how many times it was notified.

        Handlers by default get executed at the end of the playbook. Tasks will get executed immediately where they are defined. 

    - Files and templates:
        provide options for managing files. 
        Typically, the files subdirectory is used to copy over static files to destination hosts,
        whereas templates are used to generate files with dynamic contents, with help from variables
        
***

### ansible modules

#### get_url
    when will get_url set 'changed' status to true
      -  Download file already exists but checksum mismatch
      -  when force set to 'no' and checksum match, but file attributes change (which attributes?)
