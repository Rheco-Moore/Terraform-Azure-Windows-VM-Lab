# Terraform-Azure-Windows-VM-Lab
Provision a complete Azure environment using Terraform.

## Overview
Hands-on lab to practice Infrastructure as Code (IaC) fundamentals in Azure using Terraform.
The goal is **repeatable, reviewable deployments** with clear inputs/outputs and a path toward CI/CD.
This repo intentionally favors **simplicity and standards** (naming, tagging, variables) over complexity.

## Architecture 
- 1 x Resource Group
- 1 x Virtual Network (VNet) with subnets
- Network Security Groups (NSGs) with basic inbound rules
- 1 x Public IP
- 1 x Storage Account
- 1 x Windows VM attached to the VNet


## What this includes
- VNet + subnets, NSGs, public IP, storage account, Windows VM
- Variables/outputs, tagging convention
- **Remote state (planned)** via Azure Storage
- Basic lint/validate steps for CI readiness

## Prerequisites
- Terraform ≥ 1.5
- Azure subscription + `az login`
- Service principal or user auth with rights to create RG/VNet/VM
- (Optional) Backend storage account for remote state

## Project Structure
