from akhilrajmailbox/ubuntu:14.04
maintainer Akhil Raj <akhilrajmailbox@gmail.com>

run export DEBIAN_FRONTEND=noninteractive
run apt-get update && apt-get upgrade -y
run echo 'slapd/root_password password password' | debconf-set-selections \
	&& echo 'slapd/root_password_again password password' | debconf-set-selections \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils phpldapadmin apache2-utils nano

run sed -i "s|password_hash|password_hash_custom|g" /usr/share/phpldapadmin/lib/TemplateRender.php
run sed -i "s|<value id=\"/bin/tsh\">/bin/tsh</value>|<value id=\"/bin/bash\">/bin/bash</value>|g" /etc/phpldapadmin/templates/creation/posixAccount.xml
run sed -i "s|<value id=\"/bin/csh\">/bin/csh</value>|<value id=\"/bin/zsh\">/bin/zsh</value>|g" /etc/phpldapadmin/templates/creation/posixAccount.xml


run cp -r /etc/apache2 /root/apache2
run cp -r /etc/phpldapadmin /root/phpldapadmin


expose 389 80
add start.sh /root/start.sh
run chmod 777 /root/start.sh
entrypoint "/root/start.sh"
