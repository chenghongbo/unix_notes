# How to Test SMTP AUTH using Telnet

Below are instructions on how to test SMTP AUTH against a mail server using Telnet and entering the commands by hand. 

The first thing you need to do is get a base64 encoding of your username and password. There are a couple ways to do this, the example below uses Perl: 
    
    
    perl -MMIME::Base64 -e 'print encode_base64("username");'
    perl -MMIME::Base64 -e 'print encode_base64("password");'

If you have any special characters such as @ or ' or ! you must put in front of it to escape the character. 

What will be returned from each command is a base64 encoding of the username and password; save these as you will need them later. Now connect to the mail server using Telnet: 
    
    
    telnet mailserver.com 25

Greet the mail server: 
    
    
    EHLO mailserver.com

Tell the server you want to authenticate with it: 
    
    
    AUTH LOGIN

The server should have returned `334 VXNlcm5hbWU6;` this is a base64 encoded string asking you for your username, paste the base64 encoded username you created earlier, example: 
    
    
    dXNlcm5hbWUuY29t

Now the server should have returned `334 UGFzc3dvcmQ6;`. Again this is a base64 encoded string now asking for your password, paste the base64 encoded password you created, example: 
    
    
    bXlwYXNzd29yZA==

Now you should have received a message telling you that you successfully authenticated. If it failed your user/pass may have been wrong or your mailserver is broken. 

Below is a log of a real successful SMTP AUTH connection over Telnet: 
    
    
    user@localhost [~]# telnet exampledomain.com 25
    Trying 1.1.1.1...
    Connected to exampledomain.com (1.1.1.1).
    Escape character is '^]'.
    220-server1.exampledomain.com ESMTP Exim 4.66 #1 Wed, 09 May 2007 23:55:12 +0200
    220-We do not authorize the use of this system to transport unsolicited,
    220 and/or bulk e-mail.
    EHLO exampledomain.com
    250-server1.exampledomain.com Hello  [1.1.1.2]
    250-SIZE 52428800
    250-PIPELINING
    250-AUTH PLAIN LOGIN
    250-STARTTLS
    250 HELP
    AUTH LOGIN
    334 VXNlcm5hbWU6
    dXNlcm5hbWUuY29t
    334 UGFzc3dvcmQ6
    bXlwYXNzd29yZA==
    
    235 Authentication succeeded