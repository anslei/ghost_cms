# 🚀 Ghost CMS on AWS with Terraform, GitHub Actions & Semgrep

This project provisions and deploys [Ghost CMS](https://ghost.org/) on an AWS EC2 instance using:

- **Terraform** for Infrastructure-as-Code
- **GitHub Actions** for CI/CD pipeline
- **Semgrep** for static analysis (SAST)
- **Ubuntu 22.04** as the base OS
- **Free tier resources** to minimize AWS costs

---

## 📁 Project Structure

```text
.
├── .github/workflows/deploy.yml    # GitHub Actions workflow
├── main.tf                         # Terraform main configuration
├── variables.tf                    # Terraform variables
├── outputs.tf                      # Terraform outputs
├── setup.sh                        # User data script to install Ghost
└── README.md                       # This file
```

---

## ✅ What It Does

1. **Terraform** provisions:
   - One EC2 instance (t2.micro, Ubuntu 22.04)
   - Security group allowing port **22 (SSH)** and **2368 (Ghost)**
   - Associates a key pair for SSH access

2. **User Data (setup.sh)**:
   - Installs Node.js 18, NGINX, and Ghost CLI
   - Creates a `ghost` user and sets up `/var/www/ghost`
   - Installs Ghost in `local` mode
   - Configures Ghost to bind to the EC2 instance’s public IP
   - Adds systemd service to auto-start Ghost
   - Ensures proper permissions and ownership

3. **GitHub Actions**:
   - Runs `terraform init/plan/apply` automatically on push
   - Uses `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from GitHub Secrets

4. **Semgrep Integration**:
   - Scans Terraform files (`*.tf`) during CI
   - Sends findings via Slack webhook (if configured)

---

## 🛠️ How to Use

### ⚙️ Prerequisites

- AWS account with free tier enabled
- GitHub repository with these secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`
  - `TF_VAR_key_name` (your AWS EC2 key pair name)
  - `SEMGREP_APP_TOKEN` (optional, for private Semgrep rules)
  - `SLACK_WEBHOOK_URL` (optional, for reporting SAST results)

---

### 🚀 Deployment Steps

```bash
# Clone your fork
git clone https://github.com/your-username/ghost-aws-deploy.git
cd ghost-aws-deploy

# Init and deploy
terraform init
terraform apply -auto-approve
```

Ghost will be accessible on: `http://<EC2_PUBLIC_IP>:2368`

---

## 👩‍💻 Usage Notes

- Always run Ghost CLI commands as:
  ```bash
  sudo -u ghost HOME=/var/www/ghost ghost <command>
  ```

- The public IP is dynamically detected and used in Ghost’s config.
- Systemd service: `ghost-local.service` ensures Ghost runs on reboot.

---

## 🧹 .gitignore Notes

The repo ignores:
- `.terraform/`
- `terraform.tfstate*`
- `.env`, `.DS_Store`
- `*.log`, `*.bak`
- `ghost-local.service`, and user data temp files

---

## ❓ Troubleshooting

- **Security Group Already Exists**: Run `terraform import` or delete SG in AWS Console.
- **Ghost not starting via systemd**: Prefer `ghost start` over `ghost run`. Or reconfigure `systemd` as needed.
- **IP keeps changing**: Consider using Elastic IP or rerun the setup script to update Ghost's URL dynamically.

---

## 📎 References

- [Ghost Docs](https://ghost.org/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Semgrep](https://semgrep.dev/)
