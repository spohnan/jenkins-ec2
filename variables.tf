#
# DO NOT PUT KEYS OR OTHER SENSITIVE INFO IN THIS FILE
#
# The Makefile will read a text file named variables and
# put all the values into standard and terraform environment variables
#
# ---------------------------------------------------------------------

# AWS Environment Settings
# ---------------------------------------------------------------------
variable "access_key" {
  description = "The AWS access key."
}

variable "secret_key" {
  description = "The AWS secret key."
}

variable "region" {
  description = "The AWS region to create resources in."
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

variable "s3_bucket" {
  description = "S3 bucket where remote state and Jenkins data will be stored."
}

variable "s3_bucket_prefix" {
  description = "The prefix prepended to the terraform.tfstate file in the S3 bucket."
}

#
# AWS Networking Settings
# ---------------------------------------------------------------------
variable "base_cidr_block" {
  description = "The portion of the class B network for the AWS VPC 10.X.0.0/16"
}

variable "allow_traffic_from" {
  description = "A CIDR block from which we will allow traffic in the Security group"
}

variable "bastion_instance_count" {
  description = "How many bastion instances will be provisioned"
  default = 2
}

variable "bastion_instance_type" {
  description = "The type of instance used as bastion hosts within a VPC"
  default = "t2.medium"
}

variable "bastion_rolling_update_start_cron" {
  description = "Increase the number of bastion instances by one at this time"
  default = ""
}

variable "bastion_rolling_update_stop_cron" {
  description = "Decrease the number of bastion instances by one at this time"
  default = ""
}

variable "jenkins_admin_password" {
  description = "The administrator password"
}

variable "jenkins_instance_type" {
  description = "The type of instance used to run the jenkins ui"
  default = "t2.large"
}

variable "jenkins_data_disk_size_in_gb" {
  description = "The size of the EBS volume storing JENKINS_HOME"
  default = 256
}

variable "jenkins_data_delete_on_termination" {
  description = "Delete the Jenkins data disk when the instance is terminated"
  default = false
}
