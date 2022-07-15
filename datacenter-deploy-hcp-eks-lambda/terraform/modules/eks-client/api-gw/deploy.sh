#!/usr/bin/env bash
set -e


BASEDIR=$(dirname $0)

cd $BASEDIR
aws eks --region $REGION update-kubeconfig --name $CLUSTER_ID


kubectl apply --filename consul-api-gateway.yaml && \
  kubectl wait --for=condition=ready gateway/api-gateway --timeout=90s && \
  kubectl apply --filename routes.yaml