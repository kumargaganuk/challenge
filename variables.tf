# variables.tf
variable "access_key" {
     default = "XXXXXX"
}
variable "secret_key" {
     default = "XXXXXX"
}
variable "region" {
     default = "us-east-1"
}
variable "availabilityZone" {
     default = "us-east-1a"
}
variable "amivar" {
     default = "ami-096fda3c22c1c990a"
}
variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}
variable "publicsubnetCIDRblock" {
    default = "10.0.0.0/24"
}
variable "privatesubnetCIDRblock" {
    default = "10.0.1.0/24"
}
variable "destinationCIDRblock" {
    default = "0.0.0.0/0"
}
variable "instancetype" {
    default = "t2.micro"
}

