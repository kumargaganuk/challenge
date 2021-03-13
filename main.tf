# main.tf 
# Code Challenge - Create VPC/Subnet/Security Group/Network ACL
provider "aws" {
  access_key = var.access_key 
  secret_key = var.secret_key 
  region     = var.region
}

# Create vpc

resource "aws_vpc" "challenge-vpc" {
  cidr_block = var.vpcCIDRblock
  enable_dns_hostnames = true
  tags = {
    Name = "challenge-vpc"
  }
}

 # Create public  Subnet 

resource "aws_subnet" "subnet-public" {
  vpc_id            = aws_vpc.challenge-vpc.id
  cidr_block        = var.publicsubnetCIDRblock
  availability_zone = var.availabilityZone
   tags = {
    Name = "subnet-public"
  }
}

# Create private  Subnet 

resource "aws_subnet" "subnet-private" {
  vpc_id            = aws_vpc.challenge-vpc.id
  cidr_block        = var.privatesubnetCIDRblock
  availability_zone = var.availabilityZone
   tags = {
    Name = "subnet-private"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.challenge-vpc.id


}
 # Create Public Subnet Route Table

resource "aws_route_table" "route-table-public" {
  vpc_id = aws_vpc.challenge-vpc.id
   route {
    cidr_block = var.destinationCIDRblock
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Challenge-rt-public"
  }
}

# Create Private Subnet Route Table
/*resource "aws_route_table" "route-table-private" {
  vpc_id = aws_vpc.challenge-vpc.id
   route {
    cidr_block = var.vpcCIDRblock
  }
}

# Associate private subnet with Route Table
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet-private.id
  route_table_id = aws_route_table.route-table-private.id
}*/
# Associate public subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-public.id
  route_table_id = aws_route_table.route-table-public.id
}
# Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id = aws_vpc.challenge-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# Create Ec2 and install/enable nginx

resource "aws_instance" "web-server-instance" {
  ami               = var.amivar
  instance_type     = var.instancetype
  availability_zone = var.availabilityZone
  subnet_id      = aws_subnet.subnet-public.id
  associate_public_ip_address = true
  key_name          = "gagan1"
  
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install nginx -y
                sudo systemctl start nginx
                EOF
  tags = {
    Name = "nginx-web-server"
  }
}


resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_instance" "role-test" {
  ami = var.amivar
  instance_type = var.instancetype
  availability_zone = var.availabilityZone
  subnet_id      = aws_subnet.subnet-private.id
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  key_name = "gagan1"
   tags = {
      Name = "private-EC2"
  }
}
output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip

}

output "server_id" {
  value = aws_instance.web-server-instance.id
}


