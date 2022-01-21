#!/bin/bash

# 1. Go to directory and remove previous .zip files
cd ..
rm -rf keelyj.zip 
# 2. Zip master directory
zip -r keelyj .
# 3. Transfer .zip to Always Data WebDAV
curl -T keelyj.zip -u keelyj webdav-keelyj.alwaysdata.net/
#END OF SCRIPT !


