# how to renew SSL cert on startssl.com
1. login to startssl.com and re-validate your domain, if validation expired
2. go to 'certificates Wizard', click on 'DV SSL Certificate' (for free users)
3. follow the wizard and enter the hostname you'd like to request cert for (only for domains validated)
4. choose to generate CSR yourself, and do so on the Unix/Linux command line, with the following command:

`openssl req -newkey rsa:2048 -keyout sunflower.keda.io.key -out sunflower.csr -nodes \
-subj "/C=CN/ST=Guangdong/L=Shenzhen/O=keda.io/OU=DevOps/CN=sunflower.keda.io/emailAddress=acheng@keda.io"`

5. cat funflower.csr
6. paste content of your csr into the csr area
7. click submit, and in a while you'll be taken to the page with a download link
8. download the cert, unzip it, then unzip the package for your web server (Nginx/Apache ...)
9. put them in place and restart your web server
10. done