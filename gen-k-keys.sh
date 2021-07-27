#!/bin/sh

. ./common.sh

init
gen_root "ca"
gen_intermediate "interca" "ca"

gen_partner_intermediate "partnera" "interca"
gen_partner_client "validator-0" "partnera" "interca" "ca"
gen_partner_client "validator-1" "partnera" "interca" "ca"
gen_partner_client "member-0" "partnera" "interca" "ca"

gen_partner_intermediate "partnerb" "interca"
gen_partner_client "validator-2" "partnerb" "interca" "ca"
gen_partner_client "member-1" "partnerb" "interca" "ca"

gen_partner_intermediate "partnerc" "interca"
gen_partner_client "validator-3" "partnerc" "interca" "ca"
gen_partner_client "member-2" "partnerc" "interca" "ca"

gen_partner_client "validator-4" "partnera" "interca" "ca"
gen_partner_client "validator-5" "partnerb" "interca" "ca"
gen_partner_client "validator-6" "partnerc" "interca" "ca"

revoke_cert "validator-4" "partneraca"
revoke_cert "validator-5" "partneraca"
revoke_cert "validator-6" "partnerbca"

cat_crl

verify_common_cert  "validator-4" "partnera"
verify_common_cert  "validator-2" "partnerb"

copy_crl

