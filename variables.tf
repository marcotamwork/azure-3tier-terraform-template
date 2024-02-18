variable "environment" {
  type = string
  # default = "prod"
}

variable "location" {
  type = string
  # default = "East Asia"
}

variable "tf_resource_group_name" {
  default = "example-tf"
}

variable "tf_storage_account_name" {
  default = "exampletf"
}

variable "tf_container_name" {
  default = "tfstate"
}

variable "tf_file_name" {
  default = "test.terraform.tfstate"
}

variable "bypass_ip_cidr" {
  default = "127.0.0.1"
}


