echo RUN "cd ./script/_dev/ && \sudo ./INSTALL_soap_dev.pl --update-test --path-test ../../t/ByObservat-UploadFrom1c/_for_test/* --domain=soap-test.dev.gstu.by"
          cd ./script/_dev/ && sudo ./INSTALL_soap_dev.pl --update-test --path-test ../../t/ByObservat-UploadFrom1c/_for_test/* --domain=soap-test.dev.gstu.by

echo RUN "cd /var/www/webapps/soap-test.dev.gstu.by/ && find t/ByObservat-UploadFrom1c/ -iname '*.t' | sort | tr -s '\n' ' '| perl -MTest::Harness -MFindBin -e 'use lib \"\$FindBin::Bin/lib\"; runtests( split \" \", <> )'"
          cd /var/www/webapps/soap-test.dev.gstu.by/ && find t/ByObservat-UploadFrom1c/ -iname '*.t' | sort | tr -s '\n' ' '| perl -MTest::Harness -MFindBin -e 'use lib   "$FindBin::Bin/lib" ; runtests( split  " " , <> )'
