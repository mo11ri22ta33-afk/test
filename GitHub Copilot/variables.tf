variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "db_instance_type" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "wordpressdb"
}

variable "db_username" {
  type    = string
  default = "wpadmin"
}

variable "db_password" {
  description = "DB password (set via -var or TF_VAR_db_password)"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}