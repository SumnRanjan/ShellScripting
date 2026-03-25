#!/bin/bash

read -p "Enter Username : " username
echo "Username is $username"

sudo useradd -m $username

echo "New user added"
