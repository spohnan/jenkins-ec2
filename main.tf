provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "aws-ami" {
  source     = "./aws-ami"
}

module "jenkins-vpc" {
  source                = "./aws-networking/region"
  region                = "${var.region}"
  allow_traffic_from    = "${var.allow_traffic_from}"
  base_cidr_block       = "${var.base_cidr_block}"
  key_name              = "${var.key_name}"
  ec2_linux_ami_id      = "${module.aws-ami.ec2_linux_ami_id}"
  bastion_instance_type = "${var.bastion_instance_type}"
  key_name              = "${var.key_name}"
}

module "jenkins" {
  source                = "./jenkins"
  ec2_linux_ami_id      = "${module.aws-ami.ec2_linux_ami_id}"
  availability_zone     = "${module.jenkins-vpc.private_primary_subnet_az}"
  subnet_id             = "${module.jenkins-vpc.private_primary_subnet_id}"
  security_group_id     = "${module.jenkins-vpc.internal_security_group_id}"
  key_name              = "${var.key_name}"
  instance_type         = "${var.jenkins_instance_type}"
  data_disk_size_in_gb  = "${var.jenkins_data_disk_size_in_gb}"
  data_delete_on_termination = "${var.jenkins_data_delete_on_termination}"
}
