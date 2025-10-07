# Terraform Demo (for Checkov)

This directory includes a minimal AWS example with **one deliberately insecure** resource to demonstrate Checkov findings.

> Do not deploy to production as-is.

## Files
- `main.tf` – S3 bucket (one public, one private), security group with tight rules
- `variables.tf` – Inputs
- `outputs.tf` – Outputs
