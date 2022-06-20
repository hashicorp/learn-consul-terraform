#!/usr/bin/env bash

POD_NAME="${POD_NAME}"

#1. Apply Service Account creation for HashiCups
#2. Apply Deployments for HashiCups
#3.

mkdir -p /tmp/hashicups
kubectl get cm hashicups -o json | jq -r '.data."crd-intentions.yaml"' > /tmp/hashicups/crd-intentions.yaml
kubectl get cm hashicups -o json | jq -r '.data."frontend.yaml"' > /tmp/hashicups/frontend.yaml
kubectl get cm hashicups -o json | jq -r '.data."payments.yaml"' > /tmp/hashicups/payments.yaml
kubectl get cm hashicups -o json | jq -r '.data."postgres.yaml"' > /tmp/hashicups/postgres.yaml
kubectl get cm hashicups -o json | jq -r '.data."product-api.yaml"' > /tmp/hashicups/product-api.yaml
kubectl get cm hashicups -o json | jq -r '.data."public-api.yaml"' > /tmp/hashicups/public-api.yaml