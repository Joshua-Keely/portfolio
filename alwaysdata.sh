#!/bin/bash

# 1. Go to directory and remove previous .zip files
cd ..
rm -rf keelyj.zip 
# 2. Zip master directory
zip -r keelyj .
# 3. Transfer .zip to Always Data WebDAV
curl -T keelyj.zip -u keelyj webdav-keelyj.alwaysdata.net/
# 4. Connect to web server with SSH
ssh keelyj@ssh-keelyj.alwaysdata.net
# 5.  Move .zip to www
mv keelyj.zip www
cd www
# 6. Unzip Directory in www
unzip -r keelyj.zip 
# 7. Remove old files from www
rm -rf css cv img index.html projets saes scripts
# 8. Move files from master Directory to www
cd keelyj
mv -t ../ css cv img index.html saes scripts projets 
# 9. Delete empty directory and .zip 
rm -rf keelyj keelyj.zip
#END OF SCRIPT !


