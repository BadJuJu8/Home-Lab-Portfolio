# 08-pki-and-ldaps.md

## Purpose
Internal CA build, certificate issuance, LDAPS validation, trust on Linux.

## AD CS Setup
- CA name: robslab-DC01-CA
- Type: Enterprise Root CA
- Crypto: RSA 2048, SHA256
- Validity: 5 years (CA)

## Autoenrollment
- GPO applied to Domain Controllers:
  - Certificate Services Client - Auto-Enrollment enabled

## DC Certificates
- DC01 has cert(s) with Server Authentication EKU:
- Notes: multiple certs present is normal; identify which template is used.

## LDAPS
- Port: 636
- Firewall: allow TCP 636 from VLAN20 to DC01 for testing
- Validation:
  - netstat -an | findstr :636
  - Test-NetConnection DC01 -Port 636
  - openssl s_client -connect dc01.robslab.local:636 -showcerts

## Linux Trust
- Ubuntu initially failed verification:
  - unable to get local issuer certificate
- Fix: install CA cert into /usr/local/share/ca-certificates and update-ca-certificates

## Next Integration
- Create bind account svc_ldapbind
- Test ldapsearch over LDAPS

## Hardening Roadmap
- LDAP signing: start Negotiate, then Require after compatibility checks
- Channel binding: later