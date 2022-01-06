#!/bin/sh

. ./common.sh

init
gen_root "ca"
gen_intermediate "interca" "ca"

gen_root "invca"
gen_intermediate "interinvca" "invca"

gen_partner_intermediate "partnero" "interca"
gen_partner_client "orion-dns-proxy" "partnero" "interca" "ca"

gen_partner_intermediate "partnera" "interca"
gen_partner_client "partnera-firewall" "partnera" "interca" "ca"
gen_partner_client "validator1" "partnera" "interca" "ca"
gen_partner_client "validator2" "partnera" "interca" "ca"
gen_partner_client "rpcnode" "partnera" "interca" "ca"
gen_partner_client "explorer" "partnera" "interca" "ca"
gen_partner_client "member1besu" "partnera" "interca" "ca"
gen_partner_client "member1orion" "partnera" "interca" "ca"

gen_partner_intermediate "partnerb" "interca"
gen_partner_client "partnerb-firewall" "partnerb" "interca" "ca"
gen_partner_client "validator3" "partnerb" "interca" "ca"
gen_partner_client "member2besu" "partnerb" "interca" "ca"
gen_partner_client "member2orion" "partnerb" "interca" "ca"

gen_partner_intermediate "partnerc" "interca"
gen_partner_client "partnerc-firewall" "partnerc" "interca" "ca"
gen_partner_client "validator4" "partnerc" "interca" "ca"
gen_partner_client "member3besu" "partnerc" "interca" "ca"
gen_partner_client "member3orion" "partnerc" "interca" "ca"

gen_partner_intermediate "partnerinv" "interinvca"
gen_partner_client "partnerinv-firewall" "partnerc" "interinvca" "invca"
gen_partner_client "validatorinv5" "partnerinv" "interinvca" "invca"
gen_partner_client "memberinv4besu" "partnerinv" "interinvca" "invca"
gen_partner_client "memberinv4orion" "partnerinv" "interinvca" "invca"

gen_partner_client "validator5rvk" "partnera" "interca" "ca"
gen_partner_client "validator6rvk" "partnera" "interca" "ca"
gen_partner_client "validator7rvk" "partnerb" "interca" "ca"

revoke_cert "validator5rvk" "partneraca"
revoke_cert "validator6rvk" "partneraca"
revoke_cert "validator7rvk" "partnerbca"

cat_crl

verify_common_cert  "validator5rvk" "partnera" "interca" "ca"
verify_common_cert  "validator6rvk" "partnera" "interca" "ca"
verify_common_cert  "validator7rvk" "partnerb" "interca" "ca"
verify_common_cert  "validator1" "partnera"
verify_common_cert  "validator3" "partnerb"

copy_crl
