#!/bin/bash

#This script automates the file handling on the WebDAV note: this script is to be used in a ssh session placed in your home directory.

# 1. Move .zip to www
mv keelyj.zip www
# 2. Move to www and remove previous files and directory
cd www
rm -rf css cv img index.html projets saes scripts .git
# 3. Unzip .zip file    
unzip keelyj.zip
# 4. Move to directory and move files to www
cd keelyj
mv -t ../ css cv img index.html projets saes scripts
# 5. Final deletion
cd ..
rm -rf keelyj keelyj.zip
#SCRIPT ENDED
echo "Files have been updated with 0 errors"