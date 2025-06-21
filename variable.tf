variable "ec2_instance_type" {
   default  = "t3.micro"
   type     = string
}

variable "ec2_root_storage_size" {
   default  = 8
   type     = number
}

variable "ec2_ami_id" {
   default  = "ami-042b4708b1d05f512"
   type     = string
}
