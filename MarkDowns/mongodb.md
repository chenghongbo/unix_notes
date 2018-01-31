#### create Users 
```
## in mongodb shell

use test
db.createUser(
   {
     user: "mynewuser",
     pwd: "myuser123",
     roles: [ "readWrite", "dbAdmin" ]
   }
);
```

#### create admin user
```
use admin
db.createUser(
   {
     user: "myadmin1",
     pwd: "myadmin123",
     roles:
       [
         { role: "readWrite", db: "config" },
         "clusterAdmin"
       ]
   }
);
```
