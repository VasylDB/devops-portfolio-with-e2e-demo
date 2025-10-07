variable "name" { type = string }
variable "region" { type = string }
variable "subnet_ids" { type = list(string) }
variable "cluster_role_arn" { type = string }
variable "cluster_role_attachment_arns" { type = list(string) }
variable "node_role_arn" { type = string }
