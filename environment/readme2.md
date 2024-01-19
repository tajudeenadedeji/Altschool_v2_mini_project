# AltSchool Version 2 Mini_Project 
  Using Terraform, create 3 EC2 instances and put them behind an Elastic Load Balancer

  ## Project Further Explanation
  
 - Make sure the after applying your plan, Terraform exports the 

 - public IP addresses of the 3 instances to a file called host-inventory.

 - Get a .com.ng or any other domain name for yourself (be creative, this will be a domain you can keep using)

 - and set it up with AWS Route53 within your terraform plan,

 - then add an A record for subdomain terraform-test that points to your ELB IP address.

 - Create an Ansible script that uses the host-inventory file Terraform created to install Apache,

 - set timezone to Africa/Lagos and displays a simple HTML page that displays content to clearly identify on all 3 EC2 instances.

 - Your project is complete when one visits terraform-test.yoursdmain.com and it shows the content from your instances,

 - while rotating between the servers as your refresh to display their unique content.

 - Submit both the Ansible and Terraform files created
  

  ## Directories Description
  ### Environment

    This directory consist of the following files below :
    
    - apache_deployment.yaml ; 
      This is the file for the playbook that will upgrade and update the three instances ,
      set timezone to Africa/Lagos,  install apache2 ,remove index.html ,use the printf script
      to run all the necessary commands on the instances created ,it will use dedicated_server to run them.
 
    - main.tf ; 
      This files define the modules of network_vpc ,the ec2 , the application load balancer
      it also define the output and value of alb_dns_name ,ec2_public_ip and ec2_private_ip

    - Providers.tf ;
      This is the file for the terraform required provider and it also set the region and profile with their value

    - variable.tf ;
      This is where all the required variables needed to run the terraform apply are set.the required variables are region, project_name, vpc_cidr_block, 
      public_subnets_cidr, keypair_name, instance_type, domain_name and the subdomain_name_1.
      

    - terraform.tfvars ;
      The terraform.tfvars file in a Terraform project is used to store variable values that are intended to be used as inputs during the execution of Terraform commands. This file allows you to separate sensitive or environment-specific information from your main Terraform configuration files (main.tf, variables.tf, etc.) and keep it out of version control systems

  ### Modules

    This directory consist of the following sub-directories with their files below :
    - network_vpc
      main.tf :
      It contains the main.tf which creates a VPC in AWS with CIDR block
      it uses data to retreive availability zone in each region
      it create the subnets
      it create internet gateway
      it create route table and also create route table association by associating a route table with a subnet. 

      outputs.tf :
      It defines the output values of vpc_id and output value for 3 subnets count using asteric (*)

      variable.tf :
      It sets up the variables used by the network_vpc module , vpc_cidr_block , public_subnets_cid and the project_name

    - ec2
      The ec2 folder contains the same structure as the network_vpc folder but with diferent contents.
      
      main.tf :
      Use the resource to generate key pair ,private key and to create local file for private key 
      Output the public IP addresses of the instances to a file and also write the output to a file called host-inventory
      Use data to generate ubuntu AMI for the instances 
      Make a security group for the instances
      It create all the three instances and also create a dedicated_server instance to deploy the apache_deployment.yaml

      outputs.tf :
      It defines the output values of instance_ids, private_ips, public ips and the security_groups

      variable.tf :
      This is where all the required variables for the ec2 are  ,they are keypair_name, vpc_id,oject_name, public_subnets_cidr, 
      instance_type and the subnet_id.

    - application_lb :
      It is used to create an Application Load Balancer (ALB).
       
      main.tf:
      Create ALB resources including target groups, listeners and register targets.
      Use data to retrieve route53 details and also create the route53 A-record

      Outputs.tf:
      It define the output name alb_dns_name and its value
      It also define the output target_group_attach and its 
      
      variable.tf:
      This is where all the required variables needed to run the terraform apply are set.the required variables are alb_sg, alb_subnets, project_name, ec2_ids,public_subnets_cidr, keypair_name, domain_name and the subdomain_name_1.
      

      ## Domain name registration
      For this project i registered a domain name "tajudeen.com.ng" with qserver.ng
      Registered a hosted zone with aws Route 53 ,copied the 4 numbers name servers from the hosted zone to the qserver.ng my domains page

     ### Environment Setup

      ## Pre-requisites

      1. **Terraform:** Install Terraform by following the [official installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).

      2. **Ansible:** Install Ansible by following the [official installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

      3. **AWS Credentials:** Set up your AWS credentials either through environment variables or a credentials file.

      4. Git Bash

      5. GitHUB repo


     ## Directory Structure

AltSchool_mini_project/
│
├── environment/
│   ├── apache_deployment.yaml
│   ├── host_inventory
│   ├── key.pem
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── terraform.tfvars
│
└── modules/
    ├── application_lb/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── ec2/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    └── network/
        ├── main.tf
        ├── outputs.tf
        └── variables.tf

  
  ## Terraform Deployment

1. Navigate to the environment directory from the AltSchool_mini_project:
cd AltSchool_mini_project/environment

2. Initialize Terraform:
terraform init

3. Deploy Infrastructure:
terraform plan --var-file=terraform.tfvars
terraform apply --var-file=terraform.tfvars

4. Exported Host Inventory:
Terraform will automatically export the public IP addresses of the instances to a file called host_inventory in the environment directory.

  ## Ansible Playbook

  Since the user data scripts are defined in the main.tf of the ec2 directory, you don't need to manually run them. Terraform will execute these scripts during the deployment process.

  Testing
  Visit the configured domain in a web browser to verify the deployed infrastructure.

  Copy files
  Copy files needed to run the ansible playbook from the local machine to the dedicated_server instance after connecting into it on the aws console
  scp -i key.pem apache_deployment.yaml host-inventory key.pem ubuntu@35.180.62.198:/home/ubuntu
  On the console the keypair name is showing key.pem.pem but it was key.pem on my local machine ,so i used the mv command to change the keypair name from key.pem to key.pem.pem
  mv key.pem key.pem.pem
  chmod 400 key.pem.pem
  Then to chmod 700 "key.pem.pem"
  To run ansible:ansible-playbook -i host-inventory --key-file=./key.pem.pem apache_deployment.yaml --check ; it will check if everything is okay .
  if everything is perfect then run: ansible-playbook -i host-inventory --key-file=./key.pem.pem apache_deployment.yaml without --check

 ## Conclusion
  The terraform will automatically created record name:terraform-test.tajudeen.com.ng with Record tpe A and the value:project-alb-696820407.eu-west-3.elb.amazonaws.com.
  The value if copied and paste on the url it will indicate I like webserver_1 if refreshed it will change to I like webserver_2 and I like webserver_3 simultaneously.
  Whenever the terraform-test.tajudeen.com.ng is paste inside the url it will shows the content on the three instances

  Clean Up
  To destroy the Terraform infrastructure, run the following command in the environment directory:

  terraform destroy --var-file+terraform.tfvars

 ## Screenshot
 VPC 
 
 ![Alt text](<../AltSchool_v2_mini_project images/vpc.JPG>)
 
 Subnets
 
 ![Alt text](<../AltSchool_v2_mini_project images/subnets.JPG>)
 
 Igw
 
 ![Alt text](<../AltSchool_v2_mini_project images/Igw.JPG>)
 
 Application_lb
 
 ![Alt text](<../AltSchool_v2_mini_project images/application load balancer.JPG>)
 
 Route_Table
 
 ![Alt text](<../AltSchool_v2_mini_project images/route table.JPG>)
 
 Dedicated_server
 
 ![Alt text](<../AltSchool_v2_mini_project images/dedicated server.JPG>)

 Server-1

 ![Alt text](<../AltSchool_v2_mini_project images/Server-1.JPG>)

 Server-2

 ![Alt text](<../AltSchool_v2_mini_project images/server_2.JPG>)

 Server-3
 
 ![Alt text](<../AltSchool_v2_mini_project images/server_3.JPG>)

 Security_Groups
 
 ![Alt text](<../AltSchool_v2_mini_project images/security_group.JPG>)

 Target_group
 
 ![Alt text](<../AltSchool_v2_mini_project images/target group.JPG>)
 
 ansible--check
 
 ![Alt text](<../AltSchool_v2_mini_project images/ansible --check.JPG>)

 route_table
 
 ![Alt text](<../AltSchool_v2_mini_project images/route table.JPG>)

 route_53
 
 ![Alt text](<../AltSchool_v2_mini_project images/route table.JPG>)

 Project conclusion
 
 ![Alt text](<../AltSchool_v2_mini_project images/project conclusion.JPG>)



 ## Contact
  tajudeenadedejir2@gmail.com

 ## Acknowledgments
      
  Instructors and Colleagues at AltSchool Africa
      
  https://www.google.com/
      
  https://terraform.io/
      
  https://git.drupalcode.org/project/gin/-/blob/8.x-3.x/README.md

  https://www.seancdavis.com/posts/three-ways-to-add-image-to-github-readme/

  https://chat.openai.com/c/609b499f-1d33-49a1-b555-94a148ee7fe0

  https://docs.ansible.com/

      