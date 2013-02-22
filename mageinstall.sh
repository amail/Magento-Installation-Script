#!/bin/bash

# MageInstall.sh
# Shell script that simplifies the Magento installation process and configuration.
# Created by Robin Orheden <orhedenr@gmail.com> 2013

# MIT License
# Copyright (C) 2013 Robin Orheden
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

SHOW_HELP=0
CONFIG_FILE_PATH="./mageinstall.conf"
VALIDATION_MESSAGE=""

# Read command line options
index=0
options=$@
arguments=($options)

# Determine configuration file location
if [[ $1 != "" && $1 != -* ]]; then
    index=1
    CONFIG_FILE_PATH=$1
fi

# Validate that configuration exists
if [[ ! -f $CONFIG_FILE_PATH ]]; then
    echo "! Configuration file $CONFIG_FILE_PATH does not exist"
    exit
fi

# Load configuration
. $CONFIG_FILE_PATH

# Show help if no arguments are provided
for argument in $options
do
    index=`expr $index + 1`
    value=${arguments[`expr $index`]}
    case $argument in
        # Options
        # General
        -n | --name) NAME=$value;;
        -f | --force) FORCE_INSTALL=1;;
        # Web
        -w | --www-path) WWW_PATH=$value;;
        -W |--www-url) WWW_URL=$value;;
        # Database
        -N |--db-name) DB_NAME=$value;;
        -H | --db-host) DB_HOST=$value;;
        -U |--db-user) DB_USER=$value;;
        -P | --db-pass) DB_PASS=$value;;
        # Magento
        -v | --mag-version | --version) MAG_VERSION=$value;;
        -d | --mag-dev-mode) MAG_DEVELOPER_MODE=$value;;
        -F | --mag-firstname) MAG_FIRSTNAME=$value;;
        -S | --mag-surname) MAG_SURNAME=$value;;
        -e | --mag-email) MAG_EMAIL=$value;;
        -u | --mag-user) MAG_USER=$value;;
        -p | --mag-pass) MAG_PASS=$value;;
        -x | --mag-extensions)
            IFS=","
            set $value
            i=0
            for item
            do
                MAG_EXTENSIONS[$i]=$item
                ((i++))
            done
        # Actions
        --stable-versions)
            echo "* Downloading list of stable versions..."

            # Retrieve all the latest stable versions
            wget --quiet http://www.magentocommerce.com/download -O - \
                | grep -o -P '(?<=<h3 class="light-grey-head">ver ).*(?=<\/h3>)' \
                | awk '{print "  * " $0}'

            exit;;
        -h | --help) SHOW_HELP=1;;
    esac
done

# Show help!
if [ $SHOW_HELP == 1 ]; then
    echo "To run, use:"
    echo "./mageinstall.sh [[config file path]] [[option] [value]]"
    echo ""
    echo "Commands:"
    echo "--stable-versions     Get a list of all stable Magento versions"
    echo ""
    echo "Options:"
    echo "-n, --name            Name of the instance that you want to install"
    echo "-f, --force           Run without user approval"
    echo "-w, --www-path        Path where the WWW-files will be copied"
    echo "-W, --www-url         Absolute URL to where the site will be accessible"
    echo "-N, --db-name         Database name"
    echo "-H, --db-host         Database host"
    echo "-U, --db-user         Database username"
    echo "-P, --db-pass         Database password"
    echo "-e, --mag-email       Magento admin email"
    echo "-u, --mag-user        Magento admin username"
    echo "-p, --mag-pass        Magento admin password"
    echo "-v, --mag-version     Magento version to install"
    echo "-d, --mag-dev-mode    Enables the Magento developer mode in the installation"
    echo "-F, --mag-firstname   Magento admin first name"
    echo "-S, --mag-surname     Magento admin surname"
    echo "-x, --mag-extensions  Comma-separated list with Magento extensions to install"
    exit
fi

# Validate parameters

# General
if [[ -z $NAME ]]; then
    VALIDATION_MESSAGE="Configuration 'NAME' cannot be empty"
fi

if [[ -z $WWW_PATH ]]; then
    VALIDATION_MESSAGE="Configuration 'WWW_PATH' cannot be empty"
fi

# Database
if [[ -z $DB_NAME ]]; then
    VALIDATION_MESSAGE="Configuration 'DB_NAME' cannot be empty"
fi

if [[ -z $DB_HOST ]]; then
    VALIDATION_MESSAGE="Configuration 'DB_HOST' cannot be empty"
fi

if [[ -z $DB_USER ]]; then
    VALIDATION_MESSAGE="Configuration 'DB_USER' cannot be empty"
fi

if [[ -z $DB_PASS ]]; then
    VALIDATION_MESSAGE="Configuration 'DB_PASS' cannot be empty"
fi

# Magento
if [[ -z $MAG_VERSION ]]; then
    VALIDATION_MESSAGE="Configuration 'MAG_VERSION' cannot be empty"
fi

if [[ -z $MAG_DEVELOPER_MODE ]]; then
    VALIDATION_MESSAGE="Configuration 'MAG_DEVELOPER_MODE' cannot be empty"
fi

if [[ -z $MAG_FIRSTNAME ]]; then
    VALIDATION_MESSAGE="Configuration 'MAG_FIRSTNAME' cannot be empty"
fi

if [[ -z $MAG_SURNAME ]]; then
    VALIDATION_MESSAGE="Configuration 'MAG_SURNAME' cannot be empty"
fi

if [[ -z $MAG_EMAIL ]]; then
    VALIDATION_MESSAGE="Configuration 'MAG_EMAIL' cannot be empty"
fi

if [[ -z $MAG_USER ]]; then
    VALIDATION_MESSAGE="Configuration 'MAG_USER' cannot be empty"
fi

if [[ -z $MAG_PASS ]]; then
    VALIDATION_MESSAGE="Configuration 'MAG_PASS' cannot be empty"
fi

# Print message if present
if [[ ! -z $VALIDATION_MESSAGE ]]; then
    echo "! $VALIDATION_MESSAGE"
    exit
fi

# Setup directories and paths
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CACHE_DIR=$CURRENT_DIR/cache
VERSION_FILE_NAME=magento-$MAG_VERSION.tar.gz
mkdir -p $CACHE_DIR/

# Render name variables with the name variable
WWW_PATH=${WWW_PATH/\%name\%/$NAME}
WWW_URL=${WWW_URL/\%name\%/$NAME}
DB_NAME=${DB_NAME/\%name\%/$NAME}

# Verify that the user is aware of the possible consequences of the install
if [ $FORCE_INSTALL == 0 ]; then
    echo "IMPORTANT: This installation will:"
    echo " * Remove all files under the directory '$WWW_PATH'."
    printf " * Drop/create the database '$DB_NAME'.\n\n"

    # Check whether or not the user wants to continue
    read -p "Are you really sure that you want to continue y/n [n]? " -n 1
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo "* Installation aborted."
        exit 1
    fi
fi

# Handle specific versions that use old file naming convention and ZIP format
if [ $MAG_VERSION == "1.0.19870.6" ]; then
    echo "! Unsupported version $MAG_VERSION"
    exit;
fi

# Download the Magento version if it isn't cached
if [ ! -f $CACHE_DIR/$VERSION_FILE_NAME ];
then
    # Build the path to the magento archive
    version_file_url=http://www.magentocommerce.com/downloads/assets/$MAG_VERSION/$VERSION_FILE_NAME

    # Try and download the archive
    printf "* Downloading Magento version $MAG_VERSION ($VERSION_FILE_NAME)...\n"
    wget -O $CACHE_DIR/$VERSION_FILE_NAME.tmp $version_file_url 2> /dev/null
    export response_code=$?

    if [ "$response_code" = "0" ]; then
        # Successful! Rename the temp file to the original file name.
        mv $CACHE_DIR/$VERSION_FILE_NAME.tmp $CACHE_DIR/$VERSION_FILE_NAME
    else
        # File not found. Cleanup old temp files.
        rm -rf $CACHE_DIR/$VERSION_FILE_NAME.tmp
        echo "! Unable to download file. Verify that the version specified actually exist."
        echo "! $version_file_url"
        exit;
    fi
fi

# Drop and recreate old directory
rm -R $WWW_PATH 2> /dev/null
mkdir -p $WWW_PATH

# Extract files to target directory
echo "* Unpacking and preparing to install Magento to directory $WWW_PATH/..."
if [[ "$VERSION_FILE_NAME" == *.zip ]]; then
    cd $WWW_PATH
    unzip $CACHE_DIR/$VERSION_FILE_NAME 2> /dev/null
    cd $CURRENT_DIR
else
    tar -zxf $CACHE_DIR/$VERSION_FILE_NAME -C $WWW_PATH/ 2> /dev/null
fi

# Move files from extracted directory /magento/ to target directory
shopt -s dotglob
mv $WWW_PATH/magento/* $WWW_PATH/ > /dev/null
sudo rm -R $WWW_PATH/magento/ > /dev/null

# Set file permissions
chmod -R o+w $WWW_PATH/media $WWW_PATH/var > /dev/null
chmod o+w $WWW_PATH/app/etc > /dev/null
rm -rf $WWW_PATH/downloader/pearlib/cache/* $WWW_PATH/downloader/pearlib/download/* > /dev/null

# Create the database if it doesn't exist
echo "* Recreating database $DB_NAME..."
mysql -u$DB_USER -p$DB_PASS -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME;"

cd $WWW_PATH

# Run installer
echo "* Installing Magento..."
installation_result=`php -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "en_GB" \
    --timezone "Europe/London" \
    --default_currency "GBP" \
    --db_host "$DB_HOST" \
    --db_name "$DB_NAME" \
    --db_user "$DB_USER" \
    --db_pass "$DB_PASS" \
    --url "$WWW_URL" \
    --use_rewrites "yes" \
    --use_secure "no" \
    --secure_base_url "" \
    --use_secure_admin "no" \
    --skip_url_validation "yes" \
    --admin_firstname "$MAG_FIRSTNAME" \
    --admin_lastname "$MAG_SURNAME" \
    --admin_email "$MAG_EMAIL" \
    --admin_username "$MAG_USER" \
    --admin_password "$MAG_PASS"` > /dev/null

# Check whether the Mage CLI is present. Should be for versions >=1.5
if [ -f ./mage ]; then
    chmod +x ./mage > /dev/null
    ./mage mage-setup > /dev/null

    # Check whether there are extensions to install
    if [ ${#MAG_EXTENSIONS[@]} > 0 ]; then
        for extension_name in "${MAG_EXTENSIONS[@]}"
        do
            echo "* Installing extension $extension_name..."
            ./mage install community $extension_name > /dev/null
        done
    fi
fi

# Check that the installation was successful
if [[ "$installation_result" != *SUCCESS* ]]
then
    echo "! Installation failed. Installation returned: $installation_result"
    exit
fi

# Enable developer mode
if [ $MAG_DEVELOPER_MODE == 1 ]; then
    sed -i -e '/Mage::run/i\
Mage::setIsDeveloperMode(true);
' -e '1,$s//Mage::run/' $WWW_PATH/index.php
fi

# Master, we did okay. We did okay...
echo "* Installation successfully completed. Access site at: $WWW_URL"