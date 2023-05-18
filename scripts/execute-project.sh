#!/usr/bin/env bash
terraform init --backend-config=config/backend.conf
terraform plan --var-file=config/vars.tfvars --out=plan.tfplan
terraform apply plan.tfplan