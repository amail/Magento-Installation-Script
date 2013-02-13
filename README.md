MageInstall.sh
==============

Magento Installation Script. Shell script that simplifies the Magento installation process and configuration.

  Usage

    ./mageinstall [[config file path]] [[option] [value]]

*If no configuration path is provided, './mageinstall-conf.sh' is assumed.*

  Commands

    --stable-versions      Get a list of all stable Magento versions

  Options
  
    --name             Name of the instance that you want to install
    --force            Run without user approval
    --www-path         Path where the WWW-files will be copied
    --www-url          Absolute URL to where the site will be accessible
    --db-name          Database name
    --db-host          Database host
    --db-user          Database username
    --db-pass          Database password
    --mag-email        Magento admin email
    --mag-user         Magento admin username
    --mag-pass         Magento admin password
    --mag-version      Magento version to install
    --mag-dev-mode     Enables the Magento developer mode in the installation
    --mag-firstname    Magento admin first name
    --mag-surname      Magento admin surname

    -h, --help         Output usage information

  License (MIT)
    
    Copyright (C) 2013 Robin Orheden
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
