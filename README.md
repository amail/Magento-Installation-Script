MageInstall.sh
==============

Magento Installation Script. Shell script that simplifies the Magento installation process and configuration.

  Usage

    ./mageinstall.sh [[config file path]] [[option] [value]]

*If no configuration path is provided, './mageinstall.conf' is assumed.*

  Commands

    --stable-versions      Get a list of all stable Magento versions
    -h, --help             Output usage information

  Options
  
    -n, --name             Name of the instance that you want to install
    -f, --force            Run without user approval
    -w, --www-path         Path where the WWW-files will be copied
    -W, --www-url          Absolute URL to where the site will be accessible
    -N, --db-name          Database name
    -H, --db-host          Database host
    -U, --db-user          Database username
    -P, --db-pass          Database password
    -e, --mag-email        Magento admin email
    -u, --mag-user         Magento admin username
    -p, --mag-pass         Magento admin password
    -v, --mag-version      Magento version to install
    -d, --mag-dev-mode     Enables the Magento developer mode in the installation
    -F, --mag-firstname    Magento admin first name
    -S, --mag-surname      Magento admin surname
    -x, --mag-extensions   Comma-separated list with Magento extensions to install

  Example) Download version 1.7.0.2 into ~/www/1702dev/
  
    $ sudo ./mageinstall.sh --v 1.7.0.2 --name 1702dev --www-path ~/www/%name%/
    IMPORTANT: This installation will:
    * Remove all files under the directory '~/www/1702dev/'.
    * Drop/create the database 'magento_deploy_1702dev'.
    Are you really sure that you want to continue y/n [n]? y
    
    * Downloading Magento version 1.7.0.2 (magento-1.7.0.2.tar.gz)...
    * Unpacking and preparing to install Magento to directory ~/www/1702dev/...
    * Dropping/Creating database magento_deploy_1702dev...
    * Installing Magento...
    * Installation successfully completed. Access site at: http://localhost/1702dev/

  License (MIT)
    
    Copyright (C) 2013 Robin Orheden
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
