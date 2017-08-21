## Some windows related stuff
----

#### export DNS zone file using PowerShell
	PS C:\> Export-DnsServerZone -Name "western.contoso.com" -FileName "exportedcontoso.com"
	# file will be saved in C:\windows\system32\DNS
	
#### configure system env for JAVA_HOME in command line, on Windows

	setx /m JAVA_HOME "C:\Program Files\Java\jdk1.8.0_131"