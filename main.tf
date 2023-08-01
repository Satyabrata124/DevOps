data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



resource "aws_vpc" "main1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-1"
  }
}
resource "aws_vpc" "main2" {
  cidr_block       = "11.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-2"
  }
}

#security group
resource "aws_security_group" "example_sg" {
  name_prefix = "example_sg"
  description = "Example Security Group"

  # Replace with your desired VPC ID
  vpc_id = aws_vpc.main1.id

  # Allow inbound TCP traffic on port 22 (SSH) and 80 (HTTP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound ICMP (ping) traffic
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to all destinations (0.0.0.0/0)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "example_sg1" {
  name_prefix = "example_sg"
  description = "Example Security Group"

  # Replace with your desired VPC ID
  vpc_id = aws_vpc.main2.id

  # Allow inbound TCP traffic on port 22 (SSH) and 80 (HTTP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound ICMP (ping) traffic
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to all destinations (0.0.0.0/0)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#subnet

resource "aws_subnet" "sub-1" {
  vpc_id     = aws_vpc.main1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "subnet-1"
  }
}
resource "aws_subnet" "sub-2" {
  vpc_id     = aws_vpc.main2.id
  cidr_block = "11.0.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "subnet-2"
  }
}

#IGW
resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.main1.id

  tags = {
    Name = "igw-1"
  }
}
resource "aws_internet_gateway" "gw2" {
  vpc_id = aws_vpc.main2.id

  tags = {
    Name = "igw-2"
  }
}

#route table
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main1.id
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw1.id
  }
  

  tags = {
    Name = "routetable-1"
  }
}
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.main2.id
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw2.id
  }
  

  tags = {
    Name = "routetable-2"
  }
}

#route table association

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.sub-1.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.sub-2.id
  route_table_id = aws_route_table.rt2.id
}
#keypair creation
resource "aws_key_pair" "keypair_peer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}


#ec2 instance creationnnnnn

resource "aws_instance" "example-1" {
  ami           = data.aws_ami.ubuntu.id
   
  instance_type = "t2.micro"              # Replace with your desired instance type

 	vpc_security_group_ids = [aws_security_group.example_sg.id]
  	subnet_id = aws_subnet.sub-1.id
 	associate_public_ip_address = true
 	key_name      = aws_key_pair.keypair_peer.key_name
  tags = {
    Name = "Instance-1"
  }
}

resource "aws_instance" "example-2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

 vpc_security_group_ids = [aws_security_group.example_sg1.id]
  subnet_id = aws_subnet.sub-2.id
 associate_public_ip_address = true
 key_name      = aws_key_pair.keypair_peer.key_name
  tags = {
    Name = "Instance-2"
  }
}

#vpc peering connection
resource "aws_vpc_peering_connection" "peering" {
  peer_owner_id = "734255686032"  #replace with ur own id
  peer_vpc_id   = aws_vpc.main2.id
  vpc_id        = aws_vpc.main1.id
  auto_accept = true
}

resource "aws_route" "route_to_peer_vpc" {
  route_table_id         = aws_route_table.rt1.id
  destination_cidr_block = aws_vpc.main2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}
resource "aws_route" "route_to_peer_vpcc" {
  route_table_id         = aws_route_table.rt2.id
  destination_cidr_block = aws_vpc.main1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}




