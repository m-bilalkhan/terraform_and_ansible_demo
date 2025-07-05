# AWS EC2 Configuration and Docker Deployment with Terraform & Ansible

This project automates the provisioning and configuration of an EC2 instance using **Terraform** and **Ansible**. It creates a fully isolated AWS VPC environment, provisions a secure EC2 instance, and uses Ansible to configure the instance with required packages, a new user, Docker login, and deploys a Docker container — all using dynamic inventory and roles.

---

## 🧰 Technologies Used

- **Terraform**: Infrastructure provisioning
- **AWS Provider**: EC2, VPC, Security Groups, Route Tables, etc.
- **Ansible**: Configuration management using roles
- **Dynamic Inventory**: Automatically detect EC2 instance for Ansible
- **Docker**: Container deployment on EC2