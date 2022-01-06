#!/bin/bash

. ./common.sh

NSS_CFG_USE_COMMON="false"
NSS_DIR_PATH="./src/test/resources/keystore"

init
gen_root "ca"
gen_intermediate "interca" "ca"
gen_partner_intermediate "partner1" "interca"
gen_partner_client "partner1client1" "partner1" "interca" "ca"
gen_partner_intermediate "partner2" "interca" 
gen_partner_client "partner2client1" "partner2" "interca" "ca"

gen_root "invalidca"
gen_intermediate "invalidinterca" "invalidca"
gen_partner_intermediate "invalidpartner1" "invalidinterca"
gen_partner_client "invalidpartner1client1" "invalidpartner1" "invalidinterca" "invalidca"

print_cert "partner1client1"
print_cert "partner2client1"
print_cert "invalidpartner1client1"

gen_partner_client "partner1client2rvk" "partner1" "interca" "ca"
gen_partner_client "partner2client2rvk" "partner2" "interca" "ca"

revoke_cert "partner1client2rvk" "partner1ca"
revoke_cert "partner2client2rvk" "partner2ca"

cat_crl

verify_common_cert  "partner1client2rvk" "partner1" "interca" "ca"
verify_common_cert  "partner2client2rvk" "partner2" "interca" "ca"
verify_common_cert  "partner1client1" "partner1"
verify_common_cert  "partner2client1" "partner2"

copy_crl

