#!/bin/bash

. ./common.sh

NSS_CFG_USE_COMMON="false"
NSS_DIR_PATH="./src/test/resources/p2p-tls"

init
gen_root "ca"
gen_intermediate "interca" "ca"

gen_partner_intermediate "partnera" "interca"
gen_partner_client "validator1" "partnera" "interca" "ca"
gen_partner_client "validator" "partnera" "interca" "ca"
gen_partner_client "nonValidator" "partnera" "interca" "ca"
gen_partner_client "non-validator" "partnera" "interca" "ca"
gen_partner_client "miner1" "partnera" "interca" "ca"
gen_partner_client "node1" "partnera" "interca" "ca"

gen_partner_intermediate "partnerb" "interca"
gen_partner_client "validator2" "partnerb" "interca" "ca"
gen_partner_client "miner2" "partnerb" "interca" "ca"
gen_partner_client "node2" "partnerb" "interca" "ca"

gen_partner_intermediate "partnerc" "interca"
gen_partner_client "validator3" "partnerc" "interca" "ca"
gen_partner_client "miner3" "partnerc" "interca" "ca"

gen_partner_intermediate "partnerd" "interca"
gen_partner_client "validator4" "partnerd" "interca" "ca"
gen_partner_client "miner4" "partnerd" "interca" "ca"

gen_partner_client "miner5" "partnera" "interca" "ca"
gen_partner_client "miner6" "partnerb" "interca" "ca"

revoke_cert "miner5" "partneraca"
revoke_cert "miner6" "partnerbca"

cat_crl

verify_common_cert  "miner5" "partnera" "interca" "ca"
verify_common_cert  "miner6" "partnerb" "interca" "ca"
verify_common_cert  "miner1" "partnera"
verify_common_cert  "miner2" "partnerb"

copy_crl
