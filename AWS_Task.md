# AWS self-study task

1. **Register your own account at https://aws.amazon.com (please note that you will have to attach your credit card to your account)**

2. **Create manually base AWS infra which contains the following resources:**
    + **Create IAM Users and grant privileges:**
        - **SuperAdministrator:** 
            - "arn:aws:iam::aws:policy/AdministratorAccess"
        - **Administrator:**
            - { Effect: "Allow", Resource: "*", NotAction: [ "aws-portal:*", "iam:CreateUser", "iam:DeleteUser"]}
        - **Developer:** 
            - "arn:aws:iam::aws:policy/AmazonRoute53DomainsFullAccess"
            - "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
            - "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
            - "arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess"
            - "arn:aws:iam::aws:policy/CloudFrontFullAccess"
            - "arn:aws:iam::aws:policy/CloudWatchFullAccess"
            - "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
            - "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
            - "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
            - "arn:aws:iam::aws:policy/AmazonEC2FullAccess"

    + **Create resources stack which consists of:**
        - two EC2 instances distributed across Availability Zones;
        - S3 bucket;
        - Create IAM Instance Profile and assign it to EC2 instances (allow access to created S3 bucket)
        - two Elastic IP (attached to each instance);
        - custom security group attached to every instance;
        - EBS volumes any size attached as root device (of type magnetic);
        - Elastic Load Balancer for instances created (ELB port 80 to instance port 80);
        - Install Apache httpd on both servers and customize its welcome page on each server to contain hostname - check and ensure ELB works as expected.

    + **Modify configuration in the following way:**
        - make instances autoscaled - for this stop existing static servers and instead create Launch Configuration and Auto Scaling Group (no Elastic IPs needed this time);
        - place some files into S3 bucket from task 1 and make sure you are able to access these files from your EC2 instances
        - add Apache httpd installation to User Data section of Launch Configuration;

    + **Create stack consists of:**
        - VPC;
        - Internet Gateway;
        - Nat Gateway;
        - three Private and three public Subnets;
        - Public Route Table and Public Route;
        - Private Route Table and Private Route;

> **Note**: instance type should be t1.micro or t2.micro, AMI - official CentOS 6/7 image(s).


3. **Create the stack (ELB/EC2) using Cloudformation (JSON and YAML)**
    - **Stack specification:**
        - VPC
        - Nat Gateway;
        - One Private subnet with default route through NAT Gateway;
        - One public subnet;
        - Create Security group - allow 80 and 22 ports only (within VPC);
        - Create 2 EC2 instances (t2.micro, CentOS 7, eu-west-1) in private subnet;
        - Using userdata provision (install) Apache httpd with welcom page (get instance details from http://instance-data.ec2.internal/latest/meta-data/)
        - Create ELB (80 -> 80), assign EC2 instances as ELB backends;
        - Create Security group for ELB: allow access for EPAM-Minsk addresses only (ingress): 
            - 213.184.243.0/24
            - 217.21.56.0/24
            - 217.21.63.0/24
            - 213.184.231.0/24
            - 86.57.255.88/29
        - Create EC2 instance in public subnet for using it as Bastion (jump) server (ssh), allow ssh access from EPAM networks only. You should be able to connect to ELB backend EC2 instances (ssh) through Bastion server;
        - All resources must be tagged:
            - Name (examples: selfstudy-cfn-elb, selfstudy-cfn-web1, selfstudy-cfn-vpc, etc)
            - project (cfn)
            - role (web1, vpc, elb, web-sg, etc)

4. **Create the stack (ELB/EC2) using [terraform](https://www.terraform.io/docs/index.html)**
    - Stack specification: the same as for task #3, *project: terraform*
    - Keep terraform state file in [s3 bucket](https://www.terraform.io/docs/backends/types/s3.html)






