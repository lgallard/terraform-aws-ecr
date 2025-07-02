# AWS ECR Architecture Diagrams

This document provides architecture diagrams illustrating common usage patterns for AWS Elastic Container Registry (ECR) using the terraform-aws-ecr module.

## Basic ECR Repository Architecture

```
┌──────────────┐     ┌───────────────────────┐     ┌─────────────────┐
│              │     │                       │     │                 │
│  Developer   │────▶│    AWS ECR Registry   │◀────│  CI/CD Pipeline │
│  Workstation │     │                       │     │                 │
│              │     └───────────────────────┘     └─────────────────┘
└──────────────┘               │  ▲
                               │  │
                               ▼  │
                        ┌─────────────────┐
                        │                 │
                        │   ECS / EKS     │
                        │   Services      │
                        │                 │
                        └─────────────────┘
```

## CI/CD Integration Pattern

```
┌──────────────┐     ┌───────────────┐      ┌───────────────────┐     ┌──────────────┐
│              │     │               │      │                   │     │              │
│    Source    │────▶│   CI System   │─────▶│   AWS ECR         │────▶│  Deployment  │
│  Repository  │     │  (Build/Test) │      │   Repository      │     │    Target    │
│              │     │               │      │                   │     │  (ECS/EKS)   │
└──────────────┘     └───────────────┘      └───────────────────┘     └──────────────┘
                                                     ▲
                            ┌───────────────────────┐│
                            │                       ││
                            │ Image Scanning &      ││
                            │ Vulnerability Analysis│┘
                            └───────────────────────┘
```

## Multi-Region ECR Deployment

```
┌────────────────┐     ┌───────────────────┐
│                │     │   Primary Region  │
│  CI/CD System  │────▶│   ┌───────────┐   │
│                │     │   │    ECR    │   │
└────────────────┘     │   │           │   │
                       │   └───────────┘   │
                       └─────────┬─────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────┐
        │                                                │
        ▼                                                ▼
┌─────────────────┐                             ┌─────────────────┐
│ Secondary       │                             │ Secondary       │
│ Region A        │                             │ Region B        │
│ ┌───────────┐   │                             │ ┌───────────┐   │
│ │    ECR    │   │                             │ │    ECR    │   │
│ │  Replica  │   │                             │ │  Replica  │   │
│ └───────────┘   │                             │ └───────────┘   │
└─────────────────┘                             └─────────────────┘
```

## ECR with Security Controls

```
                              ┌───────────────────────────┐
┌──────────────────┐          │    Security Controls      │
│                  │          │                           │
│ Developer/CI     │          │  ┌───────────────────┐    │
│ Authentication   │────┐     │  │  Image Scanning   │    │
│                  │    │     │  └───────────────────┘    │
└──────────────────┘    │     │                           │
                        │     │  ┌───────────────────┐    │
                        ├────▶│  │  Access Policies  │    │
┌──────────────────┐    │     │  └───────────────────┘    │
│                  │    │     │                           │
│ Image Push/Pull  │────┘     │  ┌───────────────────┐    │
│ Operations       │──────────┼─▶│  KMS Encryption   │    │
│                  │          │  └───────────────────┘    │
└──────────────────┘          │                           │
                              └───────────────────────────┘
                                          │
                                          ▼
                              ┌───────────────────────────┐
                              │                           │
                              │     AWS ECR Repository    │
                              │                           │
                              └───────────────────────────┘
```
