# incus terraform provider

## Quickstart

### Authenticate with incus server

From the [official docs](https://linuxcontainers.org/incus/docs/main/howto/server_expose/#authenticate-with-the-incus-server):

```bash
# server
incus config trust add <client_name>

# client
incus remote add <remote_name> <token>
```

### Terraform steps

```bash
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```
