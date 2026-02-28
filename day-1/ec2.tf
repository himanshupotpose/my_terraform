provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "my_ec2_instance" {
    ami = "ami-019715e0d74f695be"
    instance_type = "t3.micro"
    key_name = "hp-key"
    vpc_security_group_ids = ["sg-03b15ce3f19883c15"]
    tags = {
        Name = "my_ec2_instance"
        env = "dev"
    }
}