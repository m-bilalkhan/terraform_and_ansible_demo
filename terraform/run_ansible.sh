#!/bin/bash
cd ../ansible/
set -e
echo "$1" > temp_key.pem
chmod 600 temp_key.pem
ansible-playbook --inventory "$2," --private-key temp_key.pem -u ubuntu playbook.yaml
rm temp_key.pem