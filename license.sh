#!/bin/bash

echo "Use of Red Hat software is governed by your agreement with Red Hat."
echo "In order to proceed, you must have a valid Red Hat subscription and software image on your system."

read -p "Do you wish to proceed? [Yes/No]  " yn
case $yn in
    [Yy]* ) echo "Thanks.";;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
esac
