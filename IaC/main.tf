terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.45"
    }
  }

  required_version = ">= 0.14.9"
}

variable "region" {
  type        = string
  description = "The AWS region"
}

variable "area" {
  type        = string
  description = "The Area"
}

variable "department" {
  type        = string
  description = "The Department"
}

variable "trust_account" {
  type        = number
  description = "The Identity (trust) account"
}

resource "aws_iam_role" "read" {
  name               = join("-", [lower(var.department), "read"])
  # region = var.region
  assume_role_policy = replace(
    file("assume_role_identity_policy.json"),
    "$${TRUST_ACCOUNT}",
    var.trust_account
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}

resource "aws_iam_role" "billing" {
  name               = join("-", [lower(var.department), "billing"])
  assume_role_policy = replace(
    file("assume_role_identity_policy.json"),
    "$${TRUST_ACCOUNT}",
    var.trust_account
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
  ]
}

resource "aws_iam_role" "admin" {
  name               = join("-", [lower(var.department), "admin"])
  assume_role_policy = replace(
    file("assume_role_identity_policy.json"),
    "$${TRUST_ACCOUNT}",
    var.trust_account
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}
