# Project: ABC Technologies - DevOps CI/CD Pipeline

## ABC-Tech Infrastructure Overview

<img width="488" height="311" alt="ABC Tech Infrastructure Diagram" src="https://github.com/user-attachments/assets/f824b353-5e4a-4127-8616-0ef10e87aa4f" />

---

## Implementation Steps

### 1. Infrastructure Provisioning (Terraform)

Provisioned complete AWS infrastructure using **Terraform**

**Resources created:**
- VPC with public subnets
- EC2 instance (for Jenkins server)
- EKS cluster with 2 worker nodes (t3.medium)
  
**Terraform Output:**

<img width="959" height="503" alt="Terraform Apply Output" src="https://github.com/user-attachments/assets/06ebb117-51df-4f1b-b45e-a0abc96e3b4b" />

**Automated installation script on EC2 for:**
- Jenkins
- Docker
- Maven
- Java 17
- kubectl
- Helm
- AWS CLI

---

### 2. Source Code Management

- Application code hosted on **GitHub**
- Repository: [https://github.com/Khanduri004/ABC-Technologies.git](https://github.com/Khanduri004/ABC-Technologies.git)
- Configured webhook for automatic Jenkins pipeline triggers

---

### 3. CI/CD Pipeline (Jenkins)

Implemented **multi-stage pipeline with 4 jobs**
1 Test
<img width="959" height="476" alt="image" src="https://github.com/user-attachments/assets/9926a740-0e41-41ff-978f-f952c85deb0f" />

2 Compile
<img width="959" height="510" alt="image" src="https://github.com/user-attachments/assets/57f0d0ab-5316-42df-8004-9afa43fd5574" />

3 Package
<img width="959" height="509" alt="image" src="https://github.com/user-attachments/assets/9c85584d-e9a0-4fd9-8602-33863029cc75" />

4 CI CD
<img width="959" height="434" alt="image" src="https://github.com/user-attachments/assets/c34e9aa5-2584-4f67-a20e-7046dd441c27" />


#### **Stage 1: Code Checkout**
- Clone repository from GitHub on every push

#### **Stage 2: Code Quality & Testing**
- Run Maven tests
- Generate code coverage report using JaCoCo
- Publish coverage report in Jenkins

#### **Stage 3: Build Application**
- Build WAR file using Maven (`mvn clean package`)
- Run unit tests

#### **Stage 4: Docker Image Build**
- Multi-stage Dockerfile
- Build application image
- Tag as `shreya004/abc_technologies:latest`

#### **Stage 5: Push to Registry**
- Push Docker image to Docker Hub
- Used Jenkins credentials for secure authentication

#### **Stage 6: Deploy to Kubernetes**
- Update kubeconfig for EKS cluster
- Apply Kubernetes manifests in order:
  1. Namespace
  2. PVC (Persistent Volume Claim)
  3. Service (NodePort on 30080)
  4. Deployment (2 replicas with resource limits)
  5. HPA (Horizontal Pod Autoscaler)

**All pods running successfully:**

<img width="659" height="247" alt="Kubernetes Pods Running" src="https://github.com/user-attachments/assets/353c1863-6fcd-4284-8f24-dc18161c8d6d" />

#### **Stage 7: Install Monitoring Stack**
- Install `kube-prometheus-stack` via Helm
- Expose services via NodePort

#### **Stage 8: Configure Monitoring**
- Configure Prometheus to scrape `/metrics` endpoint
- Verify monitoring targets

---

### 4. Monitoring & Observability

#### **Prometheus (Port 30832)**

<img width="959" height="513" alt="Prometheus Targets" src="https://github.com/user-attachments/assets/c2709dde-e18a-4051-a86d-4d2d6e47a5f1" />

#### **Grafana (Port 30081)**

<img width="959" height="440" alt="Grafana Dashboard 1" src="https://github.com/user-attachments/assets/916a0cbf-01f2-4d18-89c3-22aecf930bd7" />

<img width="959" height="478" alt="Grafana Dashboard 2" src="https://github.com/user-attachments/assets/6cec5f67-61dc-4270-ba3e-6c0f60c3668a" />

#### **AlertManager (Port 30082)**

<img width="959" height="476" alt="AlertManager Dashboard" src="https://github.com/user-attachments/assets/b90a3df0-2594-4fdc-920e-6b445723b1c2" />

---

### 5. Application Access

#### **ABC Technologies Application**

<img width="959" height="453" alt="ABC Tech Application" src="https://github.com/user-attachments/assets/b8501ded-3c88-4aa2-832f-36011f66bd0f" />

---

## Technologies Used

| Category | Technology |
|----------|------------|
| **IaC** | Terraform |
| **CI/CD** | Jenkins |
| **SCM** | GitHub |
| **Container** | Docker |
| **Orchestration** | Kubernetes (EKS) |
| **Build Tool** | Maven |
| **Monitoring** | Prometheus, Grafana, AlertManager |
| **Cloud** | AWS (EC2, EKS, VPC) |
| **Package Manager** | Helm |

---

## Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| **Application** | `http://<NODE_IP>:30080` | - |
| **Prometheus** | `http://<NODE_IP>:30832` | - |
| **Grafana** | `http://<NODE_IP>:30081` | `admin` / `admin123` |
| **AlertManager** | `http://<NODE_IP>:30082` | - |

---


## Quick Start

### Prerequisites
- AWS Account
- GitHub Account
- Docker Hub Account
- Terraform installed
- kubectl installed
- AWS CLI configured

### Deployment Steps

1. **Clone Repository**
```bash
   git clone https://github.com/Khanduri004/ABC-Technologies.git
   cd ABC-Technologies
```

2. **Deploy Infrastructure**
```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
```

3. **Configure kubectl**
```bash
   aws eks update-kubeconfig --name my-cluster --region eu-west-1
```

4. **Run Jenkins Pipeline**
   - Push code to GitHub
   - Pipeline triggers automatically
   - Monitor in Jenkins dashboard

5. **Access Application**
   - Get Node IP: `kubectl get nodes -o wide`
   - Access: `http://<NODE_IP>:30080`

---

## Author

 GitHub: [@Khanduri004](https://github.com/Khanduri004)

---

## License

MIT License
