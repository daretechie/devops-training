# ☁️ Introduction to Cloud Computing – Security & IAM (AWS Mini Project)

This concise guide demonstrates the implementation of **AWS Identity and Access Management (IAM)** for a fictional fintech startup, **Zappy e-Bank**, using best practices in cloud security. IAM is essential to safeguard resources and apply role-based access controls.

---

## 🧠 Key Concepts

### What is Cloud Computing?

Cloud computing involves delivering computing services over the internet, including servers, storage, databases, networking, software, analytics, and intelligence, to offer faster innovation, flexible resources, and economies of scale to businesses like Zappy e-Bank.


### What is IAM?

**AWS IAM (Identity and Access Management)** enables secure management of users, groups, and permissions in an AWS account. It allows:

* Creating users and assigning roles
* Defining policies to restrict or grant access
* Implementing MFA for added protection

---

## 🏗️ Project Goals

* Create IAM users and groups
* Assign custom policies for EC2 (developers) and S3 (analysts)
* Implement Multi-Factor Authentication (MFA)
* Test and validate user access permissions

---

## 🛠️ Step-by-Step Setup

### 1. **Log in to the AWS Console**

Use the root/admin account for initial setup.

### 2. **Navigate to IAM Dashboard**

Access from Services > IAM.

---

## 👥 Create IAM Users & Groups

### 🧑‍💻 Backend Developer (John)

* Needs EC2 access.
* Belongs to **Development-Team** group.

### 👩‍🔬 Data Analyst (Mary)

* Needs S3 access.
* Belongs to **Analyst-Team** group.

![IAM user creation for John and Mary](img/Screenshot%20from%202025-07-12%2019-27-18.png)

### ✅ Tasks

* Create policies named `developer` and `analyst`.
* Attach policies to respective groups.
* Add users to groups.

![Create S3 policy](img/Screenshot%20from%202025-07-12%2019-03-13.png)

![Attach policies to groups](img/Screenshot%20from%202025-07-12%2019-11-22.png)

---

## 🔐 Implement MFA

### Why MFA?

MFA adds a second layer of security. Users enter a time-based OTP from an authenticator app.

### Enable MFA for John and Mary

1. Navigate to IAM > Users > Select user
2. Click **Security credentials** > **Assign MFA device**
3. Use apps like Google Authenticator

![Assign MFA to John](img/*)
![MFA setup scan screen](img/*)

---

## 🧪 Testing IAM Access

### Test John's EC2 Access

* Log in with John’s credentials.
* Navigate to EC2 dashboard.
* Try launching or stopping an EC2 instance.

![John's EC2 access success](img/Screenshot%20from%202025-07-12%2019-37-03.png)


### Test Mary’s S3 Access

* Log in with Mary’s credentials.
* Navigate to S3 dashboard.
* Try creating or editing a bucket.

![Mary's S3 access success](img/Screenshot%20from%202025-07-12%2019-44-30.png)

### ✅ Validate Principle of Least Privilege

* John should NOT access S3.
![John should NOT access S3.](img/Screenshot%20from%202025-07-12%2019-40-43.png)

* Mary should NOT access EC2.
![Mary can't access EC2](img/Screenshot%20from%202025-07-12%2019-46-43.png)
---

## 🛠️ Troubleshooting Tips

| Issue         | Cause                      | Solution                                         |
| ------------- | -------------------------- | ------------------------------------------------ |
| Login failed  | Console access not enabled | Ensure checkbox is selected during user creation |
| Access denied | Wrong or missing policy    | Re-check attached policies and group membership  |
| MFA fails     | Device mismatch or delay   | Re-sync authenticator app and try again          |

---

## 🧾 Project Reflection

### 🛡️ Role of IAM in AWS

IAM ensures secure, organized access to AWS services.

### 👥 IAM Users vs Groups

* **Users**: Individuals like John or Mary
* **Groups**: Collections like Development-Team or Analyst-Team

### 📝 Creating Custom Policies

* Go to IAM > Policies > Create
* Choose service (e.g., EC2, S3)
* Assign actions and resources

### 🔐 Principle of Least Privilege

Only provide minimum permissions necessary for a task. Helps reduce security risks.

### 🎯 Real-World Mapping

John and Mary were configured based on job function. Their access was scoped strictly to their roles.

---

## ✅ Summary

This project demonstrates how to:

* Configure IAM users and groups
* Assign scoped policies
* Enable MFA for users
* Validate access via real AWS services

This mirrors how fintech startups and enterprises enforce secure, scalable access using AWS Identity and Access Management.

This project provides a solid foundation for managing cloud identity with confidence! 🚀
