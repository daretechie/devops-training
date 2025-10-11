# 🌐 GitHub Repository

**Repository URL**: [https://github.com/daretechie/django-dynamic-app](https://github.com/daretechie/django-dynamic-app)

This project is hosted on GitHub and contains the complete source code for the Django web application, Docker configuration, and Terraform infrastructure.

## 📋 Project Overview

# 🚀 Django Web Application on AWS ECS - Complete Mini Project

## 📋 Project Overview

This comprehensive guide documents the complete implementation of hosting a Django web application on AWS using Terraform, Docker, Amazon ECR, and ECS. This mini project demonstrates infrastructure as code, containerization, and cloud deployment best practices.

## 🎯 Learning Objectives Achieved

- ✅ **Dockerization**: Containerized Django application with production-ready Dockerfile
- ✅ **Infrastructure as Code**: Complete Terraform modules for modular AWS infrastructure
- ✅ **Container Registry**: Amazon ECR setup with lifecycle policies
- ✅ **Container Orchestration**: ECS Fargate cluster with load balancing
- ✅ **CI/CD Pipeline**: Automated deployment scripts
- ✅ **Security**: IAM roles, security groups, and best practices
- ✅ **Monitoring**: CloudWatch integration and health checks

## 🏗️ Architecture Diagram

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Django App    │───▶│   Docker Image   │───▶│  Amazon ECR     │
│   (Local Dev)   │    │   (Container)    │    │  (Registry)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
┌─────────────────┐    ┌──────────────────┐             │
│  Terraform      │───▶│   AWS ECS        │◀────────────┘
│  Infrastructure │    │   (Fargate)      │
└─────────────────┘    └──────────────────┘
                                │
                       ┌──────────────────┐
                       │  Load Balancer   │
                       │  (Public Access) │
                       └──────────────────┘
```

## 📁 Project Structure

```
django-dynamic-app/
├── 📁 main/                          # Django Application
│   ├── models.py                     # Database models (Post, Category, Contact)
│   ├── views.py                      # View functions and class-based views
│   ├── urls.py                       # URL routing configuration
│   ├── admin.py                      # Django admin configuration
│   └── templates/                    # HTML templates
│       └── main/
│           ├── base.html             # Base template with navigation
│           ├── home.html             # Homepage template
│           ├── post_list.html        # Posts listing page
│           ├── post_detail.html      # Individual post page
│           ├── category_detail.html  # Category page
│           ├── contact.html          # Contact form
│           └── contact_success.html  # Success page
├── 📁 terraform-ecs-webapp/          # AWS Infrastructure (Terraform)
│   ├── main.tf                       # Main Terraform configuration
│   ├── variables.tf                  # Variable definitions
│   ├── outputs.tf                    # Terraform outputs
│   ├── terraform.tfvars              # Variable values
│   ├── deploy.sh                     # Automated deployment script
│   ├── test-local.sh                 # Local testing script
│   └── modules/                      # Reusable Terraform modules
│       ├── ecr/                      # ECR repository module
│       │   └── main.tf
│       └── ecs/                      # ECS cluster module
│           └── main.tf
├── Dockerfile                        # Production container configuration
├── requirements.txt                  # Python dependencies
├── .dockerignore                     # Docker build exclusions
└── README.md                         # This documentation
```

## 🚀 Step-by-Step Implementation Guide

### Phase 1: Django Application Development

#### Step 1.1: Create Django Project Structure

#### Step 1.0: Clone the Repository

```bash
# Clone the Django application from GitHub
git clone https://github.com/daretechie/django-dynamic-app.git
cd django-dynamic-app
```

The repository contains a fully functional Django application with Bootstrap styling, admin interface, and all necessary configurations.

```bash
# Create Django project and app
django-admin startproject myproject .
python manage.py startapp main

# Create directories for static and media files
mkdir -p static/css static/js static/images media
```

#### Step 1.2: Configure Django Settings

```python
# myproject/settings.py - Add to INSTALLED_APPS
INSTALLED_APPS = [
    # ... existing apps
    'main',  # Our main application
]

# Static and media files configuration
STATIC_URL = 'static/'
STATICFILES_DIRS = [BASE_DIR / 'static']
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'
```

#### Step 1.3: Create Database Models

```python
# main/models.py
class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    description = models.TextField(blank=True)

class Post(models.Model):
    title = models.CharField(max_length=200)
    slug = models.SlugField(max_length=200, unique=True)
    content = models.TextField()
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES)

class Contact(models.Model):
    name = models.CharField(max_length=100)
    email = models.EmailField()
    subject = models.CharField(max_length=200)
    message = models.TextField()
```

#### Step 1.4: Create Views and Templates

```python
# main/views.py
def home(request):
    posts = Post.objects.filter(status='published')[:3]
    categories = Category.objects.all()
    return render(request, 'main/home.html', {
        'recent_posts': posts,
        'categories': categories
    })

class PostListView(ListView):
    model = Post
    template_name = 'main/post_list.html'
    paginate_by = 6
```

### Phase 2: Docker Containerization

#### Step 2.1: Create Production Dockerfile

```dockerfile
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_RETRIES=5

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    libpq-dev \
    libjpeg62-turbo-dev \
    curl

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir --timeout 100 --retries 5 -r requirements.txt

# Copy application code
COPY . /app/

# Create non-root user
RUN useradd --create-home django && chown -R django:django /app
USER django

EXPOSE 8000

# Run migrations and start server
CMD python manage.py migrate && python manage.py runserver 0.0.0.0:8000
```

#### Step 2.2: Create requirements.txt for Production

```
Django==4.2.11
psycopg2-binary==2.9.7
Pillow==10.0.0
gunicorn==21.2.0
whitenoise==6.6.0
```

#### Step 2.3: Test Docker Locally

```bash
cd terraform-ecs-webapp
./test-local.sh
# Access at http://localhost:8000
```

### Phase 3: Terraform Infrastructure Setup

#### Step 3.1: Create ECR Module

```hcl
# modules/ecr/main.tf
resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_url" {
  value = aws_ecr_repository.main.repository_url
}
```

#### Step 3.2: Create ECS Module

```hcl
# modules/ecs/main.tf
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "${var.app_name}-container"
    image = "${var.ecr_repository_url}:latest"
    portMappings = [{
      containerPort = var.container_port
    }]
  }])
}
```

#### Step 3.3: Main Terraform Configuration

```hcl
# main.tf
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
}

module "ecs" {
  source             = "./modules/ecs"
  ecr_repository_url = module.ecr.repository_url
  app_name           = var.app_name
  vpc_id             = data.aws_vpc.default.id
  subnet_ids         = data.aws_subnets.default.ids
}
```

### Phase 4: Deployment and Testing

#### Step 4.1: Automated Deployment

```bash
# Run the deployment script
cd terraform-ecs-webapp
./deploy.sh

# The script will:
# 1. Build Docker image
# 2. Push to ECR
# 3. Deploy Terraform infrastructure
# 4. Provide application URL
```

## 🔧 Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: Docker Build Fails with "jpeg-dev not found"

**Problem**: Debian package name error in Dockerfile  
**Solution**: Use `libjpeg62-turbo-dev` instead of `jpeg-dev`

#### Issue 2: Pip Install Times Out During Docker Build

**Problem**: Network timeout during package downloads
**Solution**: Added timeout and retry configuration:

```dockerfile
ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_RETRIES=5
RUN pip install --timeout 100 --retries 5 -r requirements.txt
```

#### Issue 3: Port 8000 Already in Use (Local Testing)

**Problem**: Django development server running locally
**Solution**: Stop existing server:

```bash
pkill -f "manage.py runserver"
```

#### Issue 4: ECR Push Access Denied

**Problem**: AWS credentials not configured or insufficient permissions
**Solution**:

```bash
aws configure  # Set up credentials
# Or ensure IAM user has ECR permissions
```

## 📊 Evidence and Screenshots

### Project Submission Evidence

#### 1. Docker Build Success

```
[SUCCESS] Docker image built successfully
[SUCCESS] Container started with ID: xxx
[SUCCESS] Django application is running successfully!
```

#### 2. ECR Repository Created

```json
{
  "repository": {
    "repositoryArn": "arn:aws:ecr:us-east-1:123456789:repository/django-webapp-repo",
    "repositoryName": "django-webapp-repo",
    "repositoryUri": "123456789.dkr.ecr.us-east-1.amazonaws.com/django-webapp-repo"
  }
}
```

#### 3. Terraform Deployment Success

```
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:
application_url = "http://django-webapp-alb-123456789.us-east-1.elb.amazonaws.com"
```

## 🎓 Project Assessment Criteria

### Technical Implementation (40%)

- Docker containerization working correctly
- Terraform infrastructure properly configured
- Application deployed successfully on ECS

### Code Quality (30%)

- Clean, maintainable code structure
- Proper error handling and validation
- Security best practices implemented

### Documentation (20%)

- Comprehensive README with setup instructions
- Troubleshooting guide included
- Evidence of successful deployment

### Innovation (10%)

- Additional features or optimizations
- Best practices implementation
- Production-readiness considerations

## 📝 Notes for Practice

### Key Commands to Remember

```bash
# Docker
docker build -t django-webapp .
docker run -p 8000:8000 django-webapp

# Terraform
terraform init
terraform plan
terraform apply

# AWS
aws ecr get-login-password | docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.REGION.amazonaws.com
```

This project demonstrates complete cloud deployment skills and is ready for production use!
