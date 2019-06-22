#!/bin/bash

D_KERB_REALM=MAPR.LOCAL; KERB_REALM=$D_KERB_REALM
D_DOMAIN=mapr.local; DOMAIN=$D_DOMAIN

#kdc=$(docker run -d --privileged -h $NEXTHOSTNAME -e "DOMAIN=$DOMAIN" -e "KERB_REALM=$KERB_REALM" krb5:1.10.23)

usage() {
  echo ""
  echo "$(basename $0) "
  echo "        [ -D DOMAIN ]           # Cluster network domain       (default: $D_DOMAIN)"
  echo "        [ -K REALM ]]           # -K Kerberos REALM            (default: $D_KERB_REALM)"
  echo "        [ -h ]                  # Print help message"
  echo ""
}

while getopts ":D:hK:v" OPTION
do
  case $OPTION in
    D)
      DOMAIN=$OPTARG
      ;;
    K)
      KERB_REALM=$OPTARG
      ;;
    v)
      VERBOSE=1
      ;;
    h)
      usage
      exit
      ;;
    *)
      usage "Invalid argument: $OPTARG"
      exit 1
      ;;
  esac
done

cp /etc/krb5.conf /tmp/krb5.conf
cp /var/kerberos/krb5kdc/kdc.conf /tmp/kdc.conf
cp /var/kerberos/krb5kdc/kadm5.acl /tmp/kadm5.acl
sed -i -e "s/EXAMPLE.COM/$KERB_REALM/g" -e"s/kerberos.example.com/$(hostname -f)/g" -e "s/example.com/$DOMAIN/g" /etc/krb5.conf
sed -i -e "s/EXAMPLE.COM/$KERB_REALM/g" /var/kerberos/krb5kdc/kdc.conf
/usr/sbin/kdb5_util -P mapr create -s
sed -i -e "s/EXAMPLE.COM/$KERB_REALM/g" /var/kerberos/krb5kdc/kadm5.acl
/usr/sbin/kadmin.local -q "addprinc -pw mapr mapr/admin"
/sbin/service krb5kdc start
/sbin/service kadmin start
until /sbin/service kadmin status; do
sleep 1
echo -n .
done

