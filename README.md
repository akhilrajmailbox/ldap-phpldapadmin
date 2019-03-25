
# ldap-server


docker run command ::

```

MOUNT_LOCATION=/home/akhil/Desktop/ldap-phpldapadmin/ldap-server/install
docker run --env-file env-file -v $MOUNT_LOCATION/mount/apache2:/etc/apache2 -v $MOUNT_LOCATION/mount/phpldapadmin:/etc/phpldapadmin -v $MOUNT_LOCATION/mount/ldap:/var/lib/ldap -v $MOUNT_LOCATION/mount/slapd.d:/etc/ldap/slapd.d -p <<host-port>>:80 -p <<host-port>>:389 -it --name <<container-name>> --hostname <<hostname>> akhilrajmailbox/ldap-server:latest /bin/bash

```

NOTE ::


```
here mounting four directory to host,

	/etc/apache2		=	for apache2 configuration
	/etc/phpldapadmi	=	for phpldapadmin ui confiuration
	/var/lib/ldap		=	for LDAP database
	/etc/ldap/slapd.d	=	for corresponding LDAP config files of LDAP database

```



environment variable ::

Create a file with the following variable

```
## mandatory docker variable

LDAP_ADMIN_PASS		=	The Ldap admin password
LDAP_DOMAIN		=	The FQDN for your LDAP server
LDAP_ORGANISATION	=	Your organisation name
HTPASSWORD		=	The security password for 'phpldapadmin ui' login
ALIAS			=	Redirection alias for accessing your 'phpldapadmin ui' (http://ipaddress/ALIAS)
SSL_CONFIG		=	For choosing 'HTTP' or 'HTTPs' configuration of 'phpldapadmin'

```

NOTE :::

Possible values of 'docker variable'

	*	LDAP_ADMIN_PASS		=	<<string>>
	*	LDAP_DOMAIN		=	<<string>>
	*	LDAP_ORGANISATION	=	<<string>>
	*	HTPASSWORD		=	<<string>>
	*	ALIAS			=	<<string>>
	*	SSL_CONFIG		=	Y|y|n|N (Y|y for 'HTTPS' & N|n for 'HTTP')



example environment file  ::

```
## mandatory docker variable

LDAP_ADMIN_PASS=ubuntu
LDAP_DOMAIN=akhil.system.local.in
LDAP_ORGANISATION=infra
HTPASSWORD=admin
ALIAS=myldap
SSL_CONFIG=N

```


phpldapadmin_ui ::

* security password
 
```
admin           =               admin
password        =               HTPASSWORD (you need to provide with docker run command)

```

* 'phpldapadmin ui' login password

```
admin		=		admin
password	=		LDAP_ADMIN_PASS (you need to provide with docker run command)

```



```
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
```

# ldap-client



docker run command ::

```
docker run --env-file /path/to/env-file -p <<host-port>>:22 -it --name <<container-name>> --hostname <<hostname>> akhilrajmailbox/ldap-client:latest /bin/bash

```

environment variable ::

Create a file with the following variable

### This variables are optional, if you don't provide this variables, then container will create but ldap-client will not configure, then
### run 'lets-ldap' for manual configuration of ldap client


```
BASE_DN			=	Distinguished name (dc=...,dc=...,dc=...,)
URI			=	Uniform Resource Identifier (ldap://ip-address:port)
ROOT_ADDCOUNT		=	LDAP account for root
ROOT_PASSWORD		=	LDAP root account password

```

NOTE :::

Possible values of 'docker variable'

	*	BASE_DN			=	<<string>>
	*	URI			=	<<string>>
	*	ROOT_ADDCOUNT		=	<<string>>
	*	ROOT_PASSWORD		=	<<string>>



example environment file  ::

```
BASE_DN=dc=akhil,dc=system,dc=local
URI=ldap://192.168.1.106:8995
ROOT_ADDCOUNT=cn=admin,dc=akhil,dc=system,dc=local
ROOT_PASSWORD=ubuntu

```

