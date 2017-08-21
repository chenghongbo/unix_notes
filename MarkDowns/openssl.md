#### convert pem cert to pfx format
```shell

# Your generated CSR (cert.csr)
# Your Private Key File (key.pem)
# Your SSL certificate provided by the CA (cert.cer)
# The Intermediate Certificate provided by the CA (CA.cer)

openssl pkcs12 -export -in cert.cer -inkey key.pem -out certificate.pfx -certfile CA.cer
```

#### generate self-signed cert in one command
```shell
openssl req -x509 -nodes -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365
```