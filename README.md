# CloudMaven DevOps Assessment – Full Project Documentation

## 📌 Project Overview

This project is a complete end‑to‑end DevOps pipeline designed for CloudMaven's assessment. It includes Infrastructure as Code (Terraform), containerized applications (Docker), Kubernetes deployments, monitoring & logging, and a full CI/CD pipeline using GitHub Actions.

The system deploys a **2‑tier microservice application** to an Azure Kubernetes Service (AKS) cluster.

---

## 🏗 Architecture Diagram (Description)

A typical diagram should include:

* **User → Ingress Controller → Frontend Pod**
* **Frontend Pod → Backend Pod → /api/health, /api/hello**
* **Prometheus → Metrics (Pod CPU, Memory, Request Count, Latency)**
* **Grafana Dashboards → Visualizations**
* **AKS Nodepool** inside a VNet with public/private subnets
* **Terraform Remote Backend (Azure Storage)** for storing tfstate



## ☁️ Infrastructure Deployment (Terraform)

Terraform provisions the Azure infrastructure:

### Resources Created

✔ Resource Group  
✔ Virtual Network  
✔ Subnets (Public + Private)  
✔ Network Security Groups  
✔ Route tables  
✔ AKS Cluster  
✔ Node Pools  
✔ Terraform Remote Backend (Azure Storage Account + Container)

## Terraform Deployment Steps

 Initially I created app folder
  Inside that created created two subfolders frontend & backend
 In backend created app.py and Dockerfile
Build dockerfile using

docker build -t devops-backend:local .

 verified it is running or not

 docker images

Then exposed port using (docker run -p 5000:5000 devops-backend:local)

 Then verified

curl [http://localhost:5000/health](http://localhost:5000/health)

curl [http://localhost:5000/api/hello](http://localhost:5000/api/hello)

curl [http://localhost:5000/metrics'''](http://localhost:5000/metrics)



Then used docker images to list images

 Now

created terraform files and manually from azure created a new resouce group named test26 new storage account named imranstorage26 and container named imrancontainer26

 Now inside terraform folder

 terraform init

 I got error “Error: Unreadable module directory”

How I solved
In main.tf file there was small spelling mistake I fixed that

Terraform validate Success! The configuration is valid.

 When I did tf apply I got below error

Error: A resource with the ID "/subscriptions/8b1a4af6-8eff-453b-9fac-fee5d6a811c8/resourceGroups/cloudmaven-devops-rg/providers/Microsoft.ContainerService/managedClusters/cloudmaven-devops-aks" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_kubernetes_cluster" for more information. │ │ with azurerm_kubernetes_cluster.aks, │ on main.tf line 27, in resource "azurerm_kubernetes_cluster" "aks": │ 27: resource "azurerm_kubernetes_cluster" "aks" { │

 

 #### cd terraform

 #### terraform init

 #### terraform plan

 #### terraform apply -auto-approve

 #### Kubernetes Deployment Steps



 #### kubectl apply -f k8s/app/namespace.yaml

 #### kubectl apply -f k8s/app/backend/

 #### kubectl apply -f k8s/app/frontend/

 #### kubectl apply -f k8s/app/ingress.yaml

 ## Create Application Namespace

 #### kubectl create namespace cloudmaven

## Deploy Backend

#### kubectl apply -f k8s/app/backend -n cloudmaven

## Deploy Frontend

#### kubectl apply -f k8s/app/frontend -n cloudmaven

## Deploy Ingress

#### kubectl apply -f k8s/app/ingress.yaml -n cloudmaven

## Retrieve public IP:

#### kubectl get svc -n ingress-nginx

## Test backend:

curl [http://<INGRESS-IP>/api/hello](http://<INGRESS-IP>/api/hello)

curl [http://<INGRESS-IP>/api/health](http://<INGRESS-IP>/api/health)

## Check all resources in cloudmaven namespace

#### kubectl get all -n cloudmaven

#### kubectl get deployments -n cloudmaven

## Issues Faced & Fixes

## 1. Terraform: Service CIDR Overlapping Error

Terraform AKS creation failed with error:

ServiceCidrOverlapExistingSubnetsCidr

The specified service CIDR 10.0.0.0/16 is conflicted with an existing subnet CIDR.

### Cause:

The AKS service\_cidr overlapped with the VNet subnet ranges

## Fix:

 Updated AKS network settings:

 service\_cidr       \= "10.2.0.0/24"

 dns\_service\_ip     \= "10.2.0.10"

 pod\_cidr           \= "10.244.0.0/16"

  

## 2. Terraform: Resource Already Exists / Import Required

 ### Issue:

 Terraform reported:

Resource already exists \- needs import.

### Cause:

AKS cluster was created partially before Terraform finalized.

  

## Fix:

  

 Used Terraform import:

terraform import azurerm\_kubernetes\_cluster.aks <resource\_id>

Then re-applied successfully.

## 3. Terraform: Service Principal AuthorizationFailed

### Issue:

 GitHub Actions CD job failed:

AuthorizationFailed: does not have permission to list keys

### Cause:

The Service Principal had Contributor role only on

 cloudmaven-devops-rg,

 but Terraform backend was in

test26 resource group.

### Fix:

 Granted Contributor access:

 az role assignment create \\

 --assignee <SP\_OBJECT\_ID> \\

 \--role Contributor \\

 --scope /subscriptions/.../resourceGroups/test26



## 4. Backend Health Endpoint Not Working Through Ingress

### Issue:

Direct pod test worked:

 /api/health → 200 OK

But via Ingress:404 Not Found

### Cause:

Backend routes were originally /health instead of /api/health.

  

### Fix:

Updated Flask backend:@app.route("/api/health")

Redeployed → Worked.

  

## 5. Prometheus Job “kubernetes-apiservers” Down

### Issue:

Grafana showed:Error verifying certificate x509: valid for 10.1.0.1, not 4.236.x.x

### Cause:

Prometheus tried scraping the public AKS API server, which uses TLS and cannot be scraped externally.

  

### Fix:

Edited values to disable external APIServer scraping:

 kubeAPIServer:
   enabled: false

Backend metrics started working normally.

## Nginx Rewrite Loop (500 Error) – Custom nginx.conf Not Needed

### Issue:
While accessing the frontend through Ingress, I repeatedly saw:
rewrite or internal redirection cycle while internally redirecting to "/index.html"
500 Internal Server Error

What I Initially Tried:
I attempted to fix it by adding a custom nginx.conf:

### Why This Did NOT Work:
The problem was not inside the Nginx container.
Instead, the real issues were:
Incorrect Ingress rewrite annotations

Backend using /health instead of /api/health

Ingress forwarding /api/health to a missing route

### Fixed
✔ Updated backend to use:
@app.route("/api/health")

✔ Updated Ingress paths to:
/api → backend
/ → frontend
