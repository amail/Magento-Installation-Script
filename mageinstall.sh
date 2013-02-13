#!/bin/bash

# Default
SHOW_HELP=0
CONFIG_FILE_PATH="./mageinstall-conf.sh"

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
        # General
        --name) NAME=$value;;
        --force) FORCE_INSTALL=1;;
        # Web
        --www-path) WWW_PATH=$value;;
        --www-url) WWW_URL=$value;;
        # Database
        --db-name) DB_NAME=$value;;
        --db-user) DB_USER=$value;;
        --db-host) DB_HOST=$value;;
        --db-pass) DB_PASS=$value;;
        # Magento
        --mag-version | --version) MAG_VERSION=$value;;
        --mag-dev-mode) MAG_DEVELOPER_MODE=$value;;
        --mag-firstname) MAG_FIRSTNAME=$value;;
        --mag-surname) MAG_SURNAME=$value;;
        --mag-email) MAG_EMAIL=$value;;
        --mag-user) MAG_USER=$value;;
        --mag-pass) MAG_PASS=$value;;
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

# Setup directories and paths
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CACHE_DIR=$CURRENT_DIR/cache
VERSION_FILE_NAME=magento-$MAG_VERSION.tar.gz
mkdir -p $CACHE_DIR/

# Render name variables with the name variable
WWW_PATH=${WWW_PATH/\%name\%/$NAME}
WWW_URL=${WWW_URL/\%name\%/$NAME}
DB_NAME=${DB_NAME/\%name\%/$NAME}

# Show help!
if [ $SHOW_HELP == 1 ]; then
     echo "To run, use:
     ./mageinstall [ configuration file path ]

     Options:
     ./mageinstall --name            Name of the instance that you want to install
     ./mageinstall --force           Run without user approval
     ./mageinstall --www-path        Path where the WWW-files will be copied
     ./mageinstall --www-url         Absolute URL to where the site will be accessible
     ./mageinstall --db-name         Database name
     ./mageinstall --db-host         Database host
     ./mageinstall --db-user         Database username
     ./mageinstall --db-pass         Database password
     ./mageinstall --mag-email       Magento admin email
     ./mageinstall --mag-user        Magento admin username
     ./mageinstall --mag-pass        Magento admin password
     ./mageinstall --mag-version     Magento version to install
     ./mageinstall --mag-dev-mode    Enables the Magento developer mode in the installation
     ./mageinstall --mag-firstname   Magento admin first name
     ./mageinstall --mag-surname     Magento admin surname"
     exit
fi

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
echo "* Dropping/Creating database $DB_NAME..."
mysql -u$DB_USER -p$DB_PASS -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME;"

# Run installer
cd $WWW_PATH
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
' -e '1,$s/A/a/' $WWW_PATH/index.php
fi

echo "* Installation successfully completed. Access site at: $WWW_URL"