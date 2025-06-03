# Terraform Configuration

## Workflow

```bash
cd terraform/
terraform init
terraform plan -out tfplan
terraform apply tfplan

# Generate configs for Ansible
../scripts/generate_inventory.sh
../scripts/setup_ssh_config.sh
```

## Post-Deployment

After Terraform provisions the infrastructure, use the generated scripts to configure Ansible inventory and SSH settings for cluster deployment.
