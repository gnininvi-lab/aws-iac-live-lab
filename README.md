# Enterprise Self-Service IaC Pipeline with AWS, SAST & OPA

A comprehensive, production-ready Infrastructure as Code (IaC) CI/CD pipeline lab. This architecture empowers product engineering teams to provision cloud infrastructure via self-service templates while enforcing automated security guardrails and corporate compliance policies directly within the version control lifecycle.

## Architecture & Component Overview

```text
 [Developer Workspace] -> Uses Compliant Modules -> Commits Code -> Pull Request
                                                                       │
                                                            (GitHub Actions CI/CD)
                                                                       │
                                                      ┌────────────────┴────────────────┐
                                                      ▼                                 ▼
                                              [1. Checkov SAST]                [2. OPA Policy Scan]
                                            Validates AWS Defaults           Enforces Tagging/Naming
                                                      │                                 │
                                                      └────────────────┬────────────────┘
                                                                       │
                                                                       ▼
                                                       [3. OIDC Trust Handshake]
                                                       Exchanges Short-Lived JWT
                                                                       │
                                                                       ▼
                                                       [4. Automated AWS Deploy]
                                                       Saves State to Remote S3
```





*   **Infrastructure Engine**: HashiCorp Terraform / OpenTofu utilizing the AWS provider.
*   **Self-Service Modules**: Pre-hardened templates (e.g., S3 Buckets) with embedded encryption and public access blocks.
*   **Static Application Security Testing (SAST)**: Checkov scanning engine verifying AWS infrastructure security posture before plan execution.
*   **Policy-as-Code Engine**: Open Policy Agent (OPA) via Conftest parsing execution plans (`tfplan.json`) to enforce corporate tag uniformity and naming constraints.
*   **Passwordless Authentication**: AWS IAM OpenID Connect (OIDC) federation, eliminating the need to store long-lived, high-risk AWS Access Keys inside GitHub Secrets.
*   **State Optimization**: Persistent, remote AWS S3 state backend.

---

## Pipeline Validation & Testing Lifecycle

The architecture splits deployment safety boundaries into a dual-phase pipeline.

### Phase 1: Compliance Interception & Guardrails (Pull Requests)
If an engineer attempts to deploy non-compliant configurations (e.g., lowercasing an environment identifier like `environment = "prod"` instead of using mandatory casing like `Prod`), the OPA engine instantly halts the workflow:

```text
❌ COMPLIANCE REJECTED: Bucket 'analytics_storage' must have an 'Environment' tag set exactly to 'Dev', 'Stage', or 'Prod'. Found: 'prod'
```

### Phase 2: Live Automated Provisioning (Merge to Main)
Once architectural corrections are submitted and verified, the pipeline turns green. When merged into the `main` branch, the OIDC provider assumes the secure AWS role and deploys the infrastructure live.

### Phase 3: Typical S3 Failures Triggers
When Checkov analyzes a base AWS S3 bucket declaration, it explicitly scans for three major omissions among others. They are:
*   **CKV_AWS_21 (Versioning): Missing aws_s3_bucket_versioning attachment.
*   **CKV_AWS_18 (Server Access Logging): Missing aws_s3_bucket_logging to trace incoming API requests.
*   **CKV_AWS_144 (MFA Delete): Multi-factor authentication delete configurations are omitted.

![S3 Versioning & MFA](.doc/assets/s3-bucketversioning-MFA)

![S3 Encryption](.doc/assets/s3-bucket-encryption)

![CI/CD Pipeline flagged events](.doc/assets/repository-flags)

![SAST Scan](.doc/assets/checkov-SAST-scan)

---

## Step-by-Step Lab Setup Reference

### 1. File Structure Checklist
```text
aws-iac-live-lab/
├── .github/workflows/
│   └── pipeline.yml       # GitHub Actions OIDC workflow matrix
├── modules/secure_bucket/
│   └── main.tf            # Standard hardened S3 template 
├── policy/
│   └── tags.rego          # Enterprise Rego evaluation rules
├── main.tf                # Engineer's configuration consumer
└── README.md              # Project documentation
```

### 2. AWS Pre-Requisites Runlist
Before running the workflow, execute these environment configurations inside your AWS Management Console:
*   **IAM Identity Provider**: Configure an OIDC connector pointing to `https://githubusercontent.com` with an audience of `://amazonaws.com`.
*   **IAM Deployment Role**: Generate a role named `github-actions-iac-deployer` with a trust policy bound strictly to your GitHub repository context (`repo:YOUR_GITHUB_USERNAME/aws-iac-live-lab:*`). Attach `AmazonS3FullAccess`.
*   **S3 State Storage**: Provision a private, encrypted S3 bucket to serve as the remote centralized repository for the state tracking files.

### 3. Local Workspace Sync Commands
To save this comprehensive documentation and push it live to your workspace repository, run the following commands in your VS Code terminal:

```bash
git add README.md
git commit -m "docs: compile comprehensive pipeline and architecture overview"
git push origin main
```
