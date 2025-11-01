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

---

## 🏗️ Architecture Diagram
![Architecture Diagram](assets/diagram.png)

---

### 💡 About the Author
Built with ☁️ **AWS** | 🧱 **Terraform** | 💬 **Python**
**Calvin Williams** – Cloud Computing Student | AWS & Security Enthusiast
📫 [Connect with me on LinkedIn](https://www.linkedin.com/in/calwill30)
