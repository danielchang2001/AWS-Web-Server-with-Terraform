# AWS Web Server with Terraform

Practice creating a basic web server on AWS using Terraform. It includes:

- A custom Virtual Private Cloud
- 2 public subnets within the VPC in 2 separate AZs
- 2 EC2 instances, one in each subnet
- An Application Load Balancer to load balance between the 2 instances
- An IGW attached to the VPC, and route table configuration to allow the instances to connect to the internet
- A SG to allow HTTP and SSH traffic into the EC2 instance
- An S3 bucket to store static images served by the EC2 instances (not implemented)

![Animation](https://github.com/user-attachments/assets/7cbf7610-c040-4aba-b1b5-f182551a25fe)

## Tools Used

- **Terraform**: Infrastructure as Code
- **AWS**: Cloud provider

## Architecture Diagram

![arch](https://github.com/user-attachments/assets/9800d564-5d00-41df-8ab0-af17aed79510)
