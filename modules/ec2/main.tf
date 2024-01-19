# use the resource to generate key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.rsa.public_key_openssh
}

# use resource to create private key 
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# use resource to create local file for private key 
resource "local_file" "private_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "key.pem"
}

# Output the public IP addresses of the instances to a file
output "instance_ips" {
  value = aws_instance.my_servers.*.public_ip
}

# Write the output to a file called host-inventory
resource "local_file" "host_inventory" {
  content  = join("\n", aws_instance.my_servers.*.public_ip)
  filename = "host-inventory"
}

# use data to generate ubuntu AMI for the instances 
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# make a security group for the instances 
resource "aws_security_group" "my_sg" {
  name        = "my_security_group"
  description = "Allow traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_security_group"
  }

}  


# create the instances
resource "aws_instance" "my_servers" {
  count                  = length(var.public_subnets_cidr)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.keypair_name
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  subnet_id              = var.subnet_id[count.index]
  #depends_on            = [aws_key_pair.my_key_pair]

   user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y apache2
                sudo systemctl start apache2
                sudo systemctl enable apache2
                sudo bash -c 'echo I lIKE WEB SERVER_${count.index+1} > /var/www/html/index.html'
               EOF

  tags = {
    Name = "${var.project_name}_server${count.index+1}"
  }
  
}

# create a dedicated_server instance to deploy apache_deployment.yaml
resource "aws_instance" "dedicated_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.keypair_name
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  subnet_id              = var.subnet_id[0]
  #depends_on            = [ aws_key_pair.my_key_pair ]


  user_data = <<-EOF
  #!/bin/bash
  # Update the package lists
  sudo apt-get update -y

  # Install Ansible
  sudo apt-get install ansible -y
  EOF

  tags = {
    Name = "${var.project_name}_dedicated_server"
  }
  
}