# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

Kind = "service-defaults"
Name = "payments"
Protocol  = "http"
Meta = {
  "serverless.consul.hashicorp.com/v1alpha1/lambda/enabled" = "true"
  "serverless.consul.hashicorp.com/v1alpha1/lambda/arn" = "arn:aws:lambda:us-east-1:561656980159:function:payments-lambda"
  "serverless.consul.hashicorp.com/v1alpha1/lambda/region" = "us-east-1"
}
