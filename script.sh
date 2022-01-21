#!/bin/bash

# 1. Move .zip to www
mv keelyj.zip www
# 2. Move to www and remove previous files and directory
cd www
rm -rf css cv img index.html projets saes scripts
# 3. Unzip .zip file    
unzip keelyj.zip
# 4. Move to directory and move files to www
cd keelyj
mv -t ../ css cv img index.html projets saes scripts
#SCRIPT ENDED
echo "Files have been updated with 0 errors"