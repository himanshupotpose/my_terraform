provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "my_apex" {
    ami = var.image_d
    instance_type = var.instance_type
    key_name = var.key_pair
    vpc_security_group_ids = [var.sg_id, aws_security_group.my_sg.id]
    tags = {
        Name = "my_apex"
        env = "dev"
    }   
    # heredoc
    user_data = <<-EOF
    #!/bin/bash
    apt install httpd -y
    systemctl start httpd
    systemctl enable httpd
    EOF         
}

resource "aws_security_group" "my_sg" {
    name = "new_sg"
    description = "new security group"
    vpc_id = data.aws_vpc.my_vpc.id

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 80
        to_port = 80
        protocol = "tcp"
    }
    ingress {
        cidr_blocks = ["0.0.0.0/0"] 
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
    }
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }
    egress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 0
        protocol = -1
    }
}

data "aws_vpc" "my_vpc" {
    default = true
}

variable "image_d" {
    description = "enter AMI ID"
    default = "ami-019715e0d74f695be"
}

variable "instance_type" {
    description = "enter instance type"
    default = "t3.micro"
}

variable "key_pair" {
    default = "hp-key"  
}

variable "sg_id" {
    default = "sg-03b15ce3f19883c15"
}

output "public_ip" {
    value = aws_instance.my_apex.public_ip
}