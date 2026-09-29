rm -f server.p12
rm -f server.keystore
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 -name identity -passout pass:${TLS_KEYSTORE_PASSWORD}
keytool -importkeystore -deststorepass ${TLS_KEYSTORE_PASSWORD} -destkeypass ${TLS_KEYSTORE_PASSWORD} -destkeystore server.keystore -srckeystore server.p12 -srcstoretype PKCS12 -srcstorepass ${TLS_KEYSTORE_PASSWORD} -alias identity
