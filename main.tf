provider "aws" {
    region = "ap-south-1"
}

module "my_vpc" {
    source = "./modules/vpc"
}

module "my_ec2" {
    source = "./modules/ec2"
    private_subnet_id = module.my_vpc.pri_subnet_id
    public_subnet_id = module.my_vpc.pub_subnet_id
}