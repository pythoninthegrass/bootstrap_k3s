# Terraform Configuration

## Workflow

```bash
cd terraform/
terraform init
terraform plan -out tfplan
terraform apply tfplan

# Generate configs for Ansible
../scripts/inventory.sh
```

## Post-Deployment

After Terraform provisions the infrastructure, use the generated scripts to configure Ansible inventory and SSH settings for cluster deployment.
