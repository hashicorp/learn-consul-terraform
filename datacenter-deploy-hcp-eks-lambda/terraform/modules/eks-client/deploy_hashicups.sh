#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $0)

cd $SCRIPT_DIR

aws eks --region $REGION update-kubeconfig --name $CLUSTER_ID

kubectl apply --filename hashicups/