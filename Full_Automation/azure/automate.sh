#!/bin/bash
packer build ./packer/main.json
terraform apply ./terraform/main.tf --auto-approve

