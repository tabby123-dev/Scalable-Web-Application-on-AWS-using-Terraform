# Building a Scalable Web Application on AWS with EC2, ALB, and Auto Scaling using Terraform

This project demonstrates how to build a scalable and highly available web application infrastructure on AWS using Terraform.

The infrastructure includes:

- EC2 Launch Templates
- Auto Scaling Groups (ASG)
- Application Load Balancer (ALB)
- CloudWatch Scaling Policies
- Modular Terraform Architecture

The goal of this project is to practice Infrastructure as Code (IaC) principles while building a production-style scalable AWS environment.

---

# Architecture Overview

The infrastructure consists of:

```text
Internet
    ↓
Application Load Balancer (ALB)
    ↓
Target Group
    ↓
Auto Scaling Group (ASG)
    ↓
EC2 Instances
```

---

# Features

- Modular Terraform structure
- Reusable infrastructure components
- Auto Scaling based on CPU utilization
- Load balancing across EC2 instances
- Health checks using ALB
- CloudWatch alarms and scaling policies
- Infrastructure separation by environment

---

# Project Structure

```text
terraform-project/
├── env/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── outputs.tf
│       └── provider.tf
│
├── modules/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── alb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── asg/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── backend.tf
└── provider.tf
```

---

# Why Separate Modules?

Instead of placing all infrastructure in one Terraform file, this project separates resources into dedicated modules.

## EC2 Module

Responsible for:
- Launch Templates
- Instance configuration
- AMI and instance type definitions

## ALB Module

Responsible for:
- Application Load Balancer
- Listeners
- Target Groups

## ASG Module

Responsible for:
- Auto Scaling Groups
- Scaling policies
- CloudWatch integration

---

# Benefits of Modular Design

Using separate modules provides:

- Better organization
- Reusability
- Easier debugging
- Cleaner scaling logic
- DRY (Don't Repeat Yourself) infrastructure
- Easier multi-environment deployments

---

# Module Data Flow

Terraform modules communicate through outputs and inputs.

## EC2 → ASG

The EC2 module creates a Launch Template and exports:

```hcl
output "launch_template_id" {
  value = aws_launch_template.web.id
}
```

The ASG module consumes it:

```hcl
module "asg" {
  launch_template_id = module.ec2.launch_template_id
}
```

---

## ALB → ASG

The ALB module creates a Target Group and exports:

```hcl
output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}
```

The ASG module uses it:

```hcl
module "asg" {
  target_group_arn = module.alb.target_group_arn
}
```

This creates the infrastructure connection:

```text
ALB → Target Group → ASG → EC2 Instances
```

---

# Auto Scaling Health Checks

The Auto Scaling Group uses:

```hcl
health_check_type = "ELB"
```

This tells AWS to use the ALB health checks instead of only EC2 instance checks.

---

# Why ELB Health Checks Matter

Without ELB health checks:
- EC2 may appear healthy
- but the web application itself could be broken

Examples:
- Nginx crashed
- Apache stopped responding
- application port failed

With:

```hcl
health_check_type = "ELB"
```

the ALB verifies the application is actually serving traffic correctly.

If the ALB marks an instance unhealthy:
- ASG terminates it
- launches a replacement instance
- registers the new instance automatically

This improves infrastructure reliability.

---

# Auto Scaling Workflow

When CPU usage exceeds 70%:

## Step 1 — CloudWatch Alarm Triggers

CloudWatch monitors CPU utilization.

If CPU exceeds:

```text
70%
```

the alarm enters the `ALARM` state.

---

## Step 2 — Scaling Policy Executes

The CloudWatch alarm triggers the scaling policy:

```hcl
alarm_actions = [aws_autoscaling_policy.scale_up.arn]
```

---

## Step 3 — ASG Launches New EC2 Instance

The Auto Scaling Group increases desired capacity.

Example:

```text
Desired Capacity: 2 → 3
```

---

## Step 4 — Instance Registers with ALB

The new instance:
- launches
- passes ALB health checks
- joins the target group

---

## Step 5 — Traffic is Distributed

The ALB automatically begins routing traffic to the new healthy instance.

---

# Prerequisites

Install:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

---

# Configure AWS Credentials

Authenticate with AWS:

```bash
aws configure
```

Provide:
- AWS Access Key
- AWS Secret Access Key
- Default region
- Output format

---

# Terraform Variables

Example `terraform.tfvars`:

```hcl
aws_region       = "us-east-1"
instance_type    = "t2.micro"
desired_capacity = 2
max_size         = 4
min_size         = 2
```

---

# How to Run the Project

## 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/terraform-scalable-webapp.git
```

---

## 2. Navigate to the Environment Directory

```bash
cd terraform-scalable-webapp/env/dev
```

---

## 3. Initialize Terraform

```bash
terraform init
```

This downloads:
- providers
- modules
- dependencies

---

## 4. Validate the Configuration

```bash
terraform validate
```

---

## 5. Preview Infrastructure Changes

```bash
terraform plan
```

---

## 6. Deploy Infrastructure

```bash
terraform apply
```

Type:

```text
yes
```

when prompted.

---

# Access the Application

After deployment, Terraform outputs the ALB DNS name.

Example:

```text
http://my-web-alb-123456.us-east-1.elb.amazonaws.com
```

Open the URL in your browser to access the application.

---

# Destroy Infrastructure

To avoid AWS charges:

```bash
terraform destroy
```

---

# Useful Terraform Commands

## Format Terraform Files

```bash
terraform fmt
```

## Show Current State

```bash
terraform state list
```

## View Outputs

```bash
terraform output
```

---

# Example AWS Console Verification

After deployment you should verify:

- ALB is active
- Target Group shows healthy instances
- Auto Scaling Group is healthy
- EC2 instances are running
- CloudWatch alarms are attached

---

# Future Improvements

Possible enhancements:

- Route53 custom domain
- ACM SSL certificates
- HTTPS listeners
- CI/CD with GitHub Actions
- Blue/Green deployments
- Multi-environment support
- Remote Terraform state with S3 + DynamoDB locking

---

# What I Learned

This project helped me understand:

- Terraform modules
- Infrastructure dependencies
- ALB target groups
- Auto Scaling Groups
- Launch Templates
- CloudWatch alarms
- Health checks
- Horizontal scaling
- Infrastructure as Code best practices

---

# Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/)
- [AWS ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)

---

# Author

**Tabitha Ndungu-Devops engineer **
Built as part of the **30-Day Terraform Challenge**.
