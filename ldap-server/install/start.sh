#!/bin/bash
A=$(tput sgr0)

if [ "$(ls -A /etc/apache2/)" ]; then
echo " '/etc/apache2' found"
else
cp -r /root/apache2/. /etc/apache2
fi

if [ "$(ls -A /etc/phpldapadmin)" ]; then
echo " '/etc/phpldapadmin' found"
else
cp -r /root/phpldapadmin/. /etc/phpldapadmin
fi

chown -R :www-data /etc/phpldapadmin
chown -R :www-data /etc/apache2


if [ ! -e /var/lib/ldap/bootstrapped ]; then
echo "configuring slapd for first run"

echo ""
[ -z "$LDAP_ADMIN_PASS" ] && echo -e '\E[32m'"varable error : LDAP_ADMIN_PASS $A"
[ -z "$LDAP_DOMAIN" ] && echo -e '\E[32m'"varable error : LDAP_DOMAIN $A"
[ -z "$LDAP_ORGANISATION" ] && echo -e '\E[32m'"varable error : LDAP_ORGANISATION $A"
[ -z "$HTPASSWORD" ] && echo -e '\E[32m'"varable error : HTPASSWORD $A"
[ -z "$ALIAS" ] && echo -e '\E[32m'"varable error : ALIAS $A"
[[ "$SSL_CONFIG" != [Y,y,N,n] ]] && echo -e '\E[32m'"varable error : SSL_CONFIG $A"
echo ""

sleep 3

 if [[ "$LDAP_ADMIN_PASS" = "" || "$LDAP_DOMAIN" = "" || "$LDAP_ORGANISATION" = "" || "$HTPASSWORD" = "" || $SSL_CONFIG != [Y,y,N,n] || "$ALIAS" = "" ]]; then
echo ""
echo -e '\E[33m'"---------------------------------------- $A"
echo -e '\E[33m'"|      mandatory docker variable       | $A"
echo -e '\E[33m'"---------------------------------------- $A"
echo -e '\E[33m'"---------------------------------------- $A"
echo -e '\E[33m'"|       1) LDAP_ADMIN_PASS             | $A"
echo -e '\E[33m'"---------------------------------------- $A"
echo -e '\E[33m'"|       2) LDAP_DOMAIN                 | $A"
echo -e '\E[33m'"---------------------------------------- $A"
echo -e '\E[33m'"|       3) LDAP_ORGANISATION           | $A"
echo -e '\E[33m'"---------------------------------------- $A"
echo -e '\E[33m'"|       4) HTPASSWORD                  | $A"
echo -e '\E[33m'"---------------------------------------- $A"
echo -e '\E[33m'"|       5) ALIAS                       | $A"
echo -e '\E[33m'"---------------------------------------- $A"
echo -e '\E[33m'"|       6) SSL_CONFIG                  | $A"
echo -e '\E[33m'"---------------------------------------- $A"
echo ""
#echo ""
#echo -e '\E[33m'"---------------------------------------- $A"
#echo -e '\E[33m'"|      optional docker variable        | $A"
#echo -e '\E[33m'"---------------------------------------- $A"
#echo -e '\E[33m'"---------------------------------------- $A"
#echo -e '\E[33m'"|       1) HOST_IP                     | $A"
#echo -e '\E[33m'"---------------------------------------- $A"
echo ""
echo -e '\E[32m'"###################################### $A"
echo -e '\E[32m'"###       LDAP_ADMIN_PASS          ### $A"
echo -e '\E[32m'"###################################### $A"
echo -e '\E[33m'"You need to provide the admin password for ldap admin user $A"
echo ""
echo -e '\E[32m'"###################################### $A"
echo -e '\E[32m'"###          LDAP_DOMAIN           ### $A"
echo -e '\E[32m'"###################################### $A"
echo -e '\E[33m'"FQDN need to provide $A"
echo -e '\E[33m'"example : 'akhil.system.local' $A"
echo ""
echo -e '\E[32m'"###################################### $A"
echo -e '\E[32m'"###       LDAP_ORGANISATION        ### $A"
echo -e '\E[32m'"###################################### $A"
echo -e '\E[33m'"provide ypur organisation name here $A"
echo ""
echo -e '\E[32m'"###################################### $A"
echo -e '\E[32m'"###           HTPASSWORD           ### $A"
echo -e '\E[32m'"###################################### $A"
echo -e '\E[33m'"This is the password which is used for security of 'phpldapadmin ui' $A"
echo ""
echo "USERNAME : admin"
echo "PASSWORD : The password you are providing with 'HTPASSWORD' environment variable"
echo ""
echo -e '\E[32m'"###################################### $A"
echo -e '\E[32m'"###            SSL_CONFIG          ### $A"
echo -e '\E[32m'"###################################### $A"
echo -e '\E[33m'"This directives used for choose 'HTTPS' or 'HTTP' configuration of 'phpldapadmin ui' $A"
echo -e '\E[33m'"use 'Y' or 'y' for 'HTTPS' $A"
echo -e '\E[33m'"use 'N' or 'n' for 'HTTP' $A"
echo ""
echo -e '\E[32m'"###################################### $A"
echo -e '\E[32m'"###              ALIAS             ### $A"
echo -e '\E[32m'"###################################### $A"
echo -e '\E[33m'"You can provide any word for 'ALIAS' if you wish, $A"
echo -e '\E[33m'"then you can access your LDAP server with 'http://ip-address/ALIAS' $A"
echo ""
#echo -e '\E[32m'"###################################### $A"
#echo -e '\E[32m'"###             HOST_IP            ### $A"
#echo -e '\E[32m'"###################################### $A"
#echo -e '\E[33m'"You can provide the ip-address of the docker machine if you wish, $A"
#echo ""
#echo -e '\E[33m'"If you don't provide 'HOST_IP' then It choose 'container ip' as default ip address for nrpe configuration, $A"
#echo ""
echo ""
echo -e '\E[32m'"provide all environment variable with -e option in 'docker run command' $A"
echo "aborting....!"
echo ""
exit 0
 else
echo ""
 fi

cat <<EOF | debconf-set-selections
slapd slapd/internal/generated_adminpw password $LDAP_ADMIN_PASS
slapd slapd/internal/adminpw password $LDAP_ADMIN_PASS
slapd slapd/password2 password $LDAP_ADMIN_PASS
slapd slapd/password1 password $LDAP_ADMIN_PASS
#slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/domain string $LDAP_DOMAIN
slapd shared/organization string $LDAP_ORGANISATION
slapd slapd/backend string HDB
slapd slapd/purge_database boolean false
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
EOF

dpkg-reconfigure -f noninteractive slapd


## Configure phpLDAPadmin

  if [[ ! -f /etc/apache2/htpasswd ]];then
   if [[ "$HTPASSWORD" = "" ]];then
echo "Please provide the HTPASSWORD"
echo ""
echo "USERNAME : admin"
echo "PASSWORD : The password you are providing with 'HTPASSWORD' environment variable"
echo ""
exit 0
   else
sleep 1
   fi
htpasswd -b -c /etc/apache2/htpasswd admin $HTPASSWORD
  fi

#    if [[ "$HOST_IP" = "" ]]; then
HOST_IP=`ifconfig | grep -A 1 eth0 | tail -1 | cut -d ":" -f 2 | cut -d " " -f 1`
#    fi

sed -i "s|\$servers->setValue('server','host','127.0.0.1');|#\$servers->setValue('server','host','127.0.0.1');|g" /etc/phpldapadmin/config.php
sed -i "s|\$servers->setValue('server','base',array('dc=example,dc=com'));|#\$servers->setValue('server','base',array('dc=example,dc=com'));|g" /etc/phpldapadmin/config.php
sed -i "s|\$servers->setValue('login','bind_id','cn=admin,dc=example,dc=com');|#\$servers->setValue('login','bind_id','cn=admin,dc=example,dc=com');|g" /etc/phpldapadmin/config.php
sed -i "s|?>|//?>|g" /etc/phpldapadmin/config.php


#LDAP_DOMAIN=akhil.server.in
rm -rf DOMAIN_NAME.txt
echo $LDAP_DOMAIN > DOMAIN_NAME.txt
COUNT=$(awk -F '[.]' '{print NF-1}' DOMAIN_NAME.txt | head -1)
#echo $COUNT
REAL_COUNT=$((COUNT+1))
#echo $REAL_COUNT


rm -rf DOMAIN_LIST.txt
for (( c=1; c<=$REAL_COUNT; c++ ))
do
WORD=`cat DOMAIN_NAME.txt | head -1 | cut -d "." -f $c`
echo $WORD >> DOMAIN_LIST.txt
done


data=$(
while read line
do
  echo -n "dc=${line},"
done < DOMAIN_LIST.txt)
DC_NAME=`echo $data | sed 's/.$//'`
#echo $DC_NAME
rm -rf DOMAIN_NAME.txt DOMAIN_LIST.txt


cat <<EOF >> /etc/phpldapadmin/config.php
\$servers->setValue('server','host','$HOST_IP');
\$servers->setValue('server','base',array('$DC_NAME'));
\$servers->setValue('login','bind_id','cn=admin,$DC_NAME');
\$config->custom->appearance['hide_template_warning'] = true;
?>
EOF

cp -r /etc/phpldapadmin/apache.conf /etc/phpldapadmin/apache.conf-org
sed -i "s|Alias /phpldapadmin /usr/share/phpldapadmin/htdocs|Alias /$ALIAS /usr/share/phpldapadmin/htdocs|g" /etc/phpldapadmin/apache.conf

     if [[ $SSL_CONFIG == "y" || $SSL_CONFIG == "Y" ]]
     then
echo ""
echo "configuring phpldapadmin with ssl"
rm -rf /etc/apache2/sites-available/ldap.conf

cat <<EOF >> /etc/apache2/sites-available/ldap.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ServerName $HOST_IP
    Redirect permanent /$ALIAS https://$HOST_IP/$ALIAS
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

cat <<EOF >> /etc/apache2/sites-available/ldap-second.conf
<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerAdmin webmaster@localhost
		ServerName $HOST_IP
                DocumentRoot /var/www/html
                ErrorLog \${APACHE_LOG_DIR}/error.log
                CustomLog \${APACHE_LOG_DIR}/access.log combined
                SSLEngine on
                SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
                SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>
        </VirtualHost>
</IfModule>

<Location /$ALIAS >
    AuthType Basic
    AuthName "Restricted Files"
    AuthUserFile /etc/apache2/htpasswd
    Require valid-user
</Location>
EOF

echo ""

     else

rm -rf /etc/apache2/sites-available/ldap.conf
cp -r /etc/phpldapadmin/apache.conf /etc/apache2/sites-available/ldap.conf
cat <<EOF >> /etc/apache2/sites-available/ldap.conf

<Location /$ALIAS >
    AuthType Basic
    AuthName "Restricted Files"
    AuthUserFile /etc/apache2/htpasswd
    Require valid-user
</Location>
EOF

cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/ldap-second.conf
     fi

touch /var/lib/ldap/bootstrapped

else
echo "found already-configured slapd"
fi

echo "starting slapd"

slapd
a2ensite ldap.conf
a2ensite ldap-second.conf
a2dissite 000-default.conf
a2enmod rewrite
a2enmod ssl
service apache2 restart
slapd

echo "done.....!"
tailf /root/start.sh
