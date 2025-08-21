# 🚀 Mini Project – Configuring Auto Scaling with ALB using Launch Template

This project sets up **Auto Scaling in AWS** using a **Launch Template** and an **Application Load Balancer (ALB)** to automatically add or remove EC2 instances based on demand.

---

## 🎯 Objectives

- **Launch Template:** Predefine EC2 settings for faster, consistent launches.
- **Auto Scaling Group (ASG):** Automatically maintain desired capacity.
- **Scaling Policies:** Adjust EC2 count based on demand.
- **ALB Integration:** Distribute traffic across instances.
- **Load Test:** Simulate high demand to trigger scaling.

---

## 🛠️ Steps

### **1️⃣ Create Launch Template**

1. Go to **AWS Console → EC2 → Launch Templates → Create launch template**.
2. Fill details:

   - Name: `my-launch-template`
   - AMI: Amazon Linux 2 (or preferred)
   - Instance type: `t2.micro`
   - Key pair: Existing key pair
   - Security group: Allow HTTP (80) & SSH (22)
   - User data (optional):

     ```bash
     #!/bin/bash
     yum update -y
     amazon-linux-extras install nginx1 -y
     systemctl enable nginx
     systemctl start nginx
     echo "<h1>Welcome to Auto Scaling Instance</h1>" > /usr/share/nginx/html/index.html
     ```

3. Save the template.

📷 _\[Screenshot: Launch Template configuration]_

---

### **2️⃣ Create Auto Scaling Group (ASG)**

1. Go to **AWS Console → EC2 → Auto Scaling Groups → Create Auto Scaling group**.
2. Choose **Launch Template** → select `my-launch-template`.
3. Set:

   - Name: `my-asg`
   - Desired capacity: `2`
   - Min: `1`, Max: `4`

4. Choose VPC & subnets.
5. Configure scaling policies (can be adjusted later).

📷 _\[Screenshot: ASG basic configuration]_

---

### **3️⃣ Configure Scaling Policies**

1. In the ASG → **Automatic scaling** → Create policy.
2. Choose:

   - **Target tracking policy** – Example: keep CPU utilization at 50%.
   - **Simple scaling policy** – Example: add 1 instance if CPU > 60% for 2 minutes.

📷 _\[Screenshot: Scaling policy configuration]_

---

### **4️⃣ Attach ALB to ASG**

1. Create or select an **Application Load Balancer**.
2. Add a target group.
3. In the ASG’s **Load balancing** section → Attach the ALB & target group.

📷 _\[Screenshot: ALB target group setup]_

---

### **5️⃣ Test Auto Scaling**

1. SSH into an instance from the ASG.
2. Install `stress`:

   ```bash
   sudo amazon-linux-extras install epel -y
   sudo yum install stress -y
   stress -c 4
   ```

3. Monitor **CloudWatch metrics** and see ASG add instances when CPU threshold is breached.

📷 _\[Screenshot: CloudWatch metrics showing scaling event]_

---

## 🐞 Troubleshooting

| Issue                        | Cause                          | Solution                                             |
| ---------------------------- | ------------------------------ | ---------------------------------------------------- |
| Instances not scaling        | Incorrect policy or thresholds | Lower threshold or verify CloudWatch alarms          |
| ALB not distributing traffic | Health check failure           | Check security group, target group health check path |
| Instances fail to launch     | Wrong AMI or missing key pair  | Update Launch Template with correct settings         |
| Stress tool not found        | Repo not enabled               | Run `amazon-linux-extras install epel -y`            |

---

## 💡 Key Concepts

- **Launch Template:** Blueprint for EC2 creation, including AMI, type, user data.
- **Auto Scaling Group:** Maintains desired instance count & replaces unhealthy instances.
- **Scaling Policy:** Defines when to add/remove instances.
- **ALB:** Balances traffic between multiple instances for high availability.

---

## 📸 Screenshot Checklist for Documentation

1. Launch Template details.
2. Auto Scaling Group configuration.
3. Scaling policies.
4. ALB target group & health checks.
5. CloudWatch graph showing scale-out and scale-in events.

---

## 🏁 Conclusion

This setup enables an application to **scale automatically based on demand**, **stay resilient**, and **maintain performance** without manual intervention. It’s an essential skill for deploying scalable architectures in AWS.

---

Do you want me to also **add a Bash AWS CLI version** of this project so you can automate the whole ALB + ASG + Launch Template setup from the command line? That would make it consistent with your other automation projects.
