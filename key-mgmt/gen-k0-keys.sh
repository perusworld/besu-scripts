#!/bin/sh

. ./common.sh

init
gen_root "ca"
gen_intermediate "interca" "ca"

gen_partner_intermediate "partnera" "interca"
gen_partner_client "validator-0-0" "partnera" "interca" "ca"
gen_partner_client "validator-1-0" "partnera" "interca" "ca"
gen_partner_client "member-0-0" "partnera" "interca" "ca"

gen_partner_intermediate "partnerb" "interca"
gen_partner_client "validator-2-0" "partnerb" "interca" "ca"
gen_partner_client "member-1-0" "partnerb" "interca" "ca"

gen_partner_intermediate "partnerc" "interca"
gen_partner_client "validator-3-0" "partnerc" "interca" "ca"
gen_partner_client "member-2-0" "partnerc" "interca" "ca"

gen_partner_client "validator-4-0" "partnera" "interca" "ca"
gen_partner_client "validator-5-0" "partnerb" "interca" "ca"
gen_partner_client "validator-6-0" "partnerc" "interca" "ca"

revoke_cert "validator-4-0" "partneraca"
revoke_cert "validator-5-0" "partneraca"
revoke_cert "validator-6-0" "partnerbca"

cat_crl

verify_common_cert  "validator-4-0" "partnera"
verify_common_cert  "validator-2-0" "partnerb"

copy_crl

