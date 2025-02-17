#!/bin/bash
ldapadd -x -D "cn=admin,dc=admin,dc=work,dc=gd" -W -f /etc/ldap/admin.ldif