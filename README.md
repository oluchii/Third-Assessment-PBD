# **Project Bedrock - Technical Documentation**

## **Overview**

**Project Bedrock** is focused on deploying a **microservices-based retail application** to **Amazon EKS**, using **Terraform** for Infrastructure as Code (IaC). The aim was to set up a scalable, secure, and automated infrastructure that supports both the application and the deployment pipeline.

You can access the **Project-Luu Retail Store** here:
[**Project-Luu Retail Store**](http://a6c73fe566c354dc7be14ed0f223759d-211419876.eu-west-2.elb.amazonaws.com)

---

## **Architecture Components**

### **Network Layout**

To create a secure and scalable infrastructure, the project includes:

* **VPC**: A dedicated VPC with the `10.0.0.0/24` CIDR block to host all resources.
* **Subnets**:

  * 2 **Public Subnets** in `eu-west-2a` and `eu-west-2b` for resources that require internet access.
  * 2 **Private Subnets** in the same availability zones for more secure resources.
* **NAT Gateway**: Enables resources in private subnets to access the internet while remaining isolated.
* **Internet Gateway**: Provides internet access to resources in public subnets.

The **Terraform** configuration for the VPC looks like this:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
}
```

### **Core Services**

The core components of the infrastructure include:

* **Amazon EKS Cluster**: A Kubernetes-managed service to deploy and manage microservices.
* **S3 Backend for Terraform State**: Used to store Terraform state files remotely in S3, ensuring consistency across deployments.
* **DynamoDB for State Locking**: Ensures that Terraform operations don’t conflict by locking the state file during apply.

---

## **Quick Start Guide**

### **1. Set up Remote Backend**

The first task was to set up **S3** as the backend for Terraform. This stored the state files remotely and allowed the use of **DynamoDB** for state locking during `terraform apply`.

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "prod/terraform.tfstate"
    region = "eu-west-2"
  }
}
```

To initialize Terraform with the backend:

```bash
terraform init
```

### **2. Deploy Main Infrastructure**

I deployed the VPC, subnets, and EKS cluster using **Terraform**:

1. **Preview Changes with `terraform plan`**:

   ```bash
   terraform plan
   ```

2. **Apply Changes with `terraform apply`**:

   ```bash
   terraform apply
   ```

This step provisioned all the necessary resources like the VPC, subnets, IAM roles, and the EKS cluster.

### **3. Access the Cluster**

Once the EKS cluster was provisioned, I used the following command to configure `kubectl` for accessing the cluster:

```bash
aws eks --region eu-west-2 update-kubeconfig --name project-bedrock-cluster
```

---

## **Application Components**

The application consists of several microservices deployed in the **EKS cluster**:

* **Carts Service**: Uses **DynamoDB** for storing cart data.
* **Catalog Service**: Uses **MySQL** for product information storage.
* **Checkout Service**: Uses **Redis** for caching.
* **Orders Service**: Uses **PostgreSQL** for order management.
* **UI Service**: Frontend service for user interaction.

Each service is deployed as a separate pod within the Kubernetes cluster.

---

## **CI/CD Pipeline**

I set up an automated **CI/CD pipeline** using **GitHub Actions** to handle the deployment of both the infrastructure and the application.

### **Trigger Events**

* **Push to Feature Branches**: Triggers `terraform plan` to preview changes.
* **Push to Master**: Triggers both `terraform plan` and `terraform apply` to deploy changes.
* **Pull Requests to Master**: Triggers `terraform plan` to review changes before merging.

Here’s how the GitHub Actions pipeline is configured:

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: 'eu-west-2'
```

---

## **Troubleshooting Guide**

### **Common Issues and Solutions**

1. **Pod Startup Issues**:
   **Problem**: Some pods failed to start due to insufficient resources in the node group.
   **Solution**: I scaled up the **node group** by increasing the instance size and adding more nodes to ensure there were enough resources for the pods.

2. **Ingress 404 Errors**:
   **Problem**: Ingress was returning 404 errors because the service mappings were incorrect.
   **Solution**: I reviewed and corrected the **Ingress configuration**, ensuring the backend services were properly mapped to the ALB.

3. **DNS Propagation Issues**:
   **Problem**: The DNS was not resolving correctly.
   **Solution**: I verified the **A record** in **Namecheap** and waited for the DNS changes to propagate.

---

## **Security Best Practices**

### **Network Security**

* **Private Subnets for EKS Nodes**: Ensured that EKS worker nodes were placed in private subnets, limiting their exposure to the internet.
* **No Direct Internet Access for Pods**: Pods are configured to use **NAT gateways** for external communication, if needed, keeping them isolated from the internet.

### **Access Management**

* **IAM Roles with Least Privilege**: IAM roles were configured with minimal permissions to restrict access to only what's needed for each service.
* **RBAC Enabled**: Kubernetes **Role-Based Access Control (RBAC)** was used to manage access to resources within the EKS cluster, ensuring that only authorized users could access sensitive components.

---

## **Conclusion**

This documentation provides an overview of the work completed for **Project Bedrock**, including the deployment of the **retail-store-sample-app** on **Amazon EKS**. The infrastructure was automated using **Terraform**, the application was deployed to the Kubernetes cluster, and a **CI/CD pipeline** was established using **GitHub Actions**. Security best practices were followed throughout the setup, ensuring a secure and scalable environment for the application.
