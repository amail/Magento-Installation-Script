#!/bin/bash

# MageInstall
# Default Configuration

# General
NAME=test
FORCE_INSTALL=0

# Web
WWW_PATH=/var/www/magento_%name%
WWW_URL=http://localhost/magento_%name%/

# Database
DB_NAME=magento_deploy_%name%
DB_USER=root
DB_HOST=localhost
DB_PASS=root

# Magento
MAG_VERSION=1.7.0.2
MAG_DEVELOPER_MODE=1
MAG_FIRSTNAME=admin
MAG_SURNAME=admin
MAG_EMAIL=admin@admin.com
MAG_USER=admin
MAG_PASS=admin12345