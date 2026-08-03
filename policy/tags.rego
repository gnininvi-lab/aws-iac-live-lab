package main

# Rule 1: Deny if Environment tag is missing or doesn't use PascalCase (Dev, Stage, Prod)
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    tags := resource.change.after.tags
    
    valid_envs := {"Dev", "Stage", "Prod"}
    not valid_envs[tags.Environment]
    
    msg := sprintf("❌ COMPLIANCE REJECTED: Bucket '%v' must have an 'Environment' tag set exactly to 'Dev', 'Stage', or 'Prod'. Found: '%v'", [resource.name, tags.Environment])
}

# Rule 2: Force global naming convention for Production buckets
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    tags := resource.change.after.tags
    tags.Environment == "Prod"
    
    bucket_name := resource.change.after.bucket
    not startswith(bucket_name, "corp-")
    
    msg := sprintf("❌ COMPLIANCE REJECTED: Production bucket '%v' must start with the corporate prefix 'corp-'", [bucket_name])
}

