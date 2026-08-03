# Automated IaC Self-Service & Compliance Pipeline Lab

A hands-on engineering lab simulating a secure, self-service Infrastructure as Code (IaC) pipeline. This setup empowers product teams to provision cloud infrastructure using pre-approved templates while automatically enforcing security benchmarks and enterprise compliance rules at the pull-request phase.

## Architecture & Guardrails
*   **Infrastructure as Code**: HashiCorp Terraform / OpenTofu templates for AWS.
*   **SAST Security Scanning**: Checkov scanning engine validating AWS resource security defaults.
*   **Policy Enforcement**: Open Policy Agent (OPA) via Conftest enforcing custom corporate standards.
*   **Pipeline Automation**: GitHub Actions processing validations on every branch iteration.

---

## Compliance Test Execution Lab

To validate our enterprise policy governance, we simulated a deployment using a lowercase value (`prod`) for the environment tag, violating our strict corporate naming conventions (`Dev`, `Stage`, or `Prod`).

### 1. Intercepting Non-Compliant Code (OPA Catch)
The pipeline successfully intercepted the violation during the pull request phase, failing the workflow build and blocking the unapproved infrastructure plan.

![OPA Error Failure Screenshot](doc/assets/error-screenshot.png)

> **Pipeline Output Log:**
> `❌ COMPLIANCE REJECTED: Bucket 'analytics_storage' must have an 'Environment' tag set exactly to 'Dev', 'Stage', or 'Prod'. Found: 'prod'`

### 2. Remediating and Passing Validation
Once the configuration bug was corrected to the compliant `Prod` capitalization, the pipeline automatically re-evaluated the execution plan, cleared all policy blocks, and marked the build status as successful.

![Pipeline Success Green Screenshot](doc/assets/fixed-screenshot.png)

---

## Local Validation Reference

Run these validation hooks inside your VS Code terminal to evaluate your policy conditions locally before pushing changes to GitHub:

```bash
# Generate the automated Terraform plan execution document
terraform init
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Evaluate the localized compliance policies against your plan artifact
conftest test tfplan.json --policy policy/
```
