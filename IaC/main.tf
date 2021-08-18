terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.45"
    }
  }

  required_version = ">= 0.14.9"
}
/**
 * Standard variables
 */
variable "area" {
  type        = string
  description = "The Area"
}

variable "department" {
  type        = string
  description = "The Department"
}

variable "region" {
  type        = string
  description = "The AWS region"
}

variable "package" {
  type        = string
  description = "The Package"
  default     = "Unknown"
}

variable "who" {
  type        = string
  description = "Who did deployment"
  default     = "Unknown"
}

variable "digest" {
  type        = string
  description = "The docker image Digest"
  default     = "Unknown"
}

/* AWS provider and default tags */
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Package    = var.package
      Area       = var.area
      Department = var.department
      Who        = var.who
      Digest     = var.digest
    }
  }
}

variable "trust_account" {
  type        = number
  description = "The Identity (trust) account"
}

resource "aws_iam_role" "read" {
  name = join("-", [lower(var.department), "read"])
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
  name = join("-", [lower(var.department), "billing"])
  assume_role_policy = replace(
    file("assume_role_identity_policy.json"),
    "$${TRUST_ACCOUNT}",
    var.trust_account
  )

  max_session_duration = 28800 # 8 hours. 

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
  ]
}

resource "aws_iam_role" "admin" {
  name = join("-", [lower(var.department), "admin"])
  assume_role_policy = replace(
    file("assume_role_identity_policy.json"),
    "$${TRUST_ACCOUNT}",
    var.trust_account
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}
