#!/bin/bash

# This script creates file and changes his permission to 755

FILE_NAME=$1

touch $FILE_NAME
chmod 755 $FILE_NAME
