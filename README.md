# ☁️ Serverless Contact Form API (AWS)

**Author:** Calvin Williams — Cloud Computing Student | AWS & Security Enthusiast

## What this is
A small **serverless backend** that accepts a contact message (name, email, message) and saves it to **DynamoDB** using:
- **API Gateway** (POST `/contact`)
- **AWS Lambda (Python)**
- **Amazon DynamoDB**
- **Terraform** (Infrastructure as Code)

## How it flows

```
Client (curl / web form)

→ API Gateway (POST /contact)

→ Lambda (Python)

→ DynamoDB (stores the item)
```
