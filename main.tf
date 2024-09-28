# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Use existing VPC (implied by the existing subnet)
data "aws_vpc" "existing" {
  id = data.aws_subnet.existing.vpc_id
}

# Use existing subnet
data "aws_subnet" "existing" {
  id = "subnet-0cde12349d323bd3c"
}

# Create EC2 Instance
resource "aws_instance" "main" {
  ami           = "ami-02b49a24cfb95941c"
  instance_type = "t2.micro"
  key_name      = "hello"
  subnet_id     = data.aws_subnet.existing.id
  vpc_security_group_ids = ["sg-02538a61c2797d7e8"]

  tags = {
    Name = "Main EC2 Instance"
  }
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "main" {
  name        = "main-api"
  description = "Main API Gateway"
}

# Create a resource (endpoint) for the API Gateway
resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "test"
}

# Create a GET method for the resource
resource "aws_api_gateway_method" "main" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.main.id
  http_method   = "GET"
  authorization = "NONE"
}

# Create a mock integration for the method
resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  type        = "MOCK"
}

# Create API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  depends_on = [aws_api_gateway_integration.main]

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "prod"

  lifecycle {
    create_before_destroy = true
  }
}
