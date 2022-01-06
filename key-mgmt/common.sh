#!/bin/bash

NSSPIN="test123"
STOREPASS="test123"
CWD=$(pwd)
SHA="sha256"
RSA="rsa:2048"
DAYS="36500"
NSS_CFG_USE_COMMON="true"
NSS_DIR_PATH=""

init() {
    mkdir -p generated/keys
    mkdir -p generated/export
    rm -rf generated/keys/* generated/export/*
    cd generated/keys
    touch crl-index
    echo 00 > crl-number
}

print_cert() {
    keytool -printcert -v -file $1.der
}

init_nssdb() {
    mkdir -p ../export/$1/nssdb
    rm -rf ../export/$1/nssdb/*.db
    echo "$NSSPIN" > ../export/$1/nsspin.txt
    certutil -N -d dbm:../export/$1/nssdb -f ../export/$1/nsspin.txt
}

import_ca() {
    echo "importing ca cert $2.der into ../export/$1/nssdb"
    certutil -A -d dbm:../export/$1/nssdb -n "$2" -t "CT,C,C" -f ../export/$1/nsspin.txt -i $2.der
    echo "importing ca cert $2.crt into ../export/$1/truststore.jks"
    keytool -importcert -trustcacerts -noprompt -alias $2 -storetype JKS -storepass $STOREPASS -keystore ../export/$1/truststore.jks -file $2.der 
}

import_client() {
    echo "importing client keys $1.pfx into ../export/$1/nssdb"
    pk12util -d dbm:../export/$1/nssdb -k ../export/$1/nsspin.txt -w ../export/$1/nsspin.txt -i $1.pfx -n $1
    echo "importing client keys $1.pfx into ../export/$1/keystore.jks"
    keytool -importkeystore -noprompt -srcstoretype PKCS12 -srcstorepass $STOREPASS -deststorepass $STOREPASS -destkeystore ../export/$1/keystore.jks -srckeystore $1.pfx 
}

gen_p12() {
    # Create p12 file
    echo "creating p12 for $1 with $2.crts chain certs"
    openssl pkcs12 -export -out $1.pfx -inkey $1.key -in $1.crt -certfile $2.crts -password pass:"$NSSPIN" -name $1
}

copy_p12() {
    # Copy p12 file
    echo "copying p12 for $1"
    cp $1.pfx ../export/$1/keys.p12
}

gen_crl() {
    openssl ca -gencrl -keyfile $1.key -cert $1.crt -out $1_crl.pem -config ../../ssl.conf
    openssl crl -in $1_crl.pem -noout -text
}

cat_crl() {
    cat *_crl.pem  > crl.pem
}

gen_root() {
    # Generate self signed root CA cert
    openssl req -days $DAYS -$SHA -nodes -x509 -newkey $RSA -keyout $1.key -out $1.crt -extensions v3_ca -subj "/C=US/ST=CA/L=SFO/O=MC/OU=root/CN=root$1.admin/emailAddress=root$1@admin.com"

    # Create DER file
    openssl x509 -outform der -in $1.crt -out $1.der

    # Create CER file
    openssl x509 -outform pem -in $1.crt -out $1.cer

    cat $1.cer > $1.crts

    # Create PEM file
    cat $1.key $1.crt > $1.pem

    # Create p12 file
    openssl pkcs12 -export -out $1.pfx -inkey $1.key -in $1.crt -password pass:"$NSSPIN"

}

gen_signed() {
    # Generate cert to be signed
    openssl req -nodes -newkey $RSA -keyout $1.key -out $1.csr -subj "/C=US/ST=CA/L=SFO/O=MC/OU=root/CN=$1/emailAddress=$1@$2.com"

    # Sign the cert
    openssl x509 -req -days $DAYS -$SHA -in $1.csr -CA $3.crt -extfile ../../ssl.conf -extensions $4  -CAkey $3.key -CAcreateserial -out $1.crt -setalias "$1"

    # Create DER file
    openssl x509 -outform der -in $1.crt -out $1.der

    # Create CER file
    openssl x509 -outform pem -in $1.crt -out $1.cer

    # Create PEM file
    cat $1.key $1.crt > $1.pem

}

gen_intermediate() {
    gen_signed "$1" "admin" "$2" "v3_inter_ca"

    cat $1.cer $2.cer > $1.crts

    gen_p12 "$1" "$2"
}

gen_partner_intermediate() {
    gen_signed "$1ca" "$1" "$2" "v3_partner_inter_ca"

    cat "$1ca.cer" $2.crts > "$1ca.crts"

    gen_p12 "$1ca" "$2"
}

gen_partner_client() {
    init_nssdb "$1"
    gen_signed "$1" "$2" "$2ca" "usr_cert"
    cat "$1.cer" "$2ca.crts" > "$1.crts"
    cat "$1.key" "$1.crts" > ../export/$1/ssl.pem
    cat "$2ca.crts" > ../export/$1/ssl-ca.pem
    gen_p12 "$1" "$2ca"
    copy_p12 "$1"
    import_ca "$1" "$4"
    import_ca "$1" "$3"
    import_ca "$1" "$2ca"
    import_client "$1"
    SEC_MOD_DIR="/opt/besu/p2p-tls/nssdb"
    if [[ "$NSS_CFG_USE_COMMON" == "false" ]]
    then
        if [[ "$NSS_DIR_PATH" == "" ]]
        then
            SEC_MOD_DIR="$CWD/generated/nssdb/$1/nssdb"
        else
            SEC_MOD_DIR="$NSS_DIR_PATH/$1/nssdb"
        fi
    fi
    echo "
name = NSScrypto-$1
nssSecmodDirectory = $SEC_MOD_DIR
nssDbMode = readOnly
nssModule = keystore
    " >> ../export/$1/nss.cfg
}

revoke_cert() {
    openssl ca -revoke $1.crt -keyfile $2.key -cert $2.crt -config ../../ssl.conf

    #generate crl
    gen_crl "$2"

}

verify_cert() {
    cat $2ca.crts $2ca_crl.pem > test.pem
    openssl verify -extended_crl -verbose -CAfile test.pem -crl_check $1.crt
}

verify_common_cert() {
    cat $2ca.crts crl.pem > test.pem
    openssl verify -extended_crl -verbose -CAfile test.pem -crl_check $1.crt
}

copy_crl() {
    for d in ../export/*; do cp crl.pem "$d"; done    
}
