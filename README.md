Resources:

    AWS Provider:
        Configures the AWS provider to use a specific region.

    AWS EC2 Instance (nginx):
        Launches an EC2 instance with the specified AMI ID and instance type.
        Attaches to a security group that allows HTTP (port 80).
        Runs a user data script to install and start Nginx.

    AWS Security Group (nginx_sg):
        Creates a security group to allow inbound HTTP traffic (port 80).
        Allows all outbound traffic.

    AWS Application Load Balancer (ALB, nginx_lb):
        Sets up an internet-facing ALB.
        Associates it with a security group and subnets.
        Specifies load balancer properties, such as deletion protection.

    AWS Target Group (nginx_target_group):
        Creates a target group to forward traffic to the Nginx instance on port 80.
        Defines a health check for the Nginx server.

    AWS ALB Listener (nginx_listener):
        Configures the ALB to listen on port 80 and forward traffic to the target group.

    AWS Target Group Attachment (nginx_attachment):
        Attaches the EC2 instance to the ALB target group to route traffic.

    AWS Route 53 Record (dev_record):
        Creates a DNS A record for the ALB in Route 53 using an alias.

    Data Sources:
        Fetches the default VPC and subnets for the AWS region.
