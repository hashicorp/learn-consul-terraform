#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $0)

cd $SCRIPT_DIR
aws eks --region $REGION update-kubeconfig --name $CLUSTER_ID

# Destroy is false; create hashicups
if [[ $DESTROY -eq 1  ]]
then
  kubectl apply --filename hashicups/
elif [[ $DESTROY -eq 0 ]]
kubectl get gateways            --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch gateways {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get servicedefaults     --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch servicedefaults {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get servicesplitters    --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch servicesplitters {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get terminatinggateways --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch terminatinggateways {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get serviceintentions   --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch serviceintentions {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get gatewayclasses      --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch gatewayclasses {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get gatewayclassconfigs --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch gatewayclassconfigs {} -p '{"metadata":{"finalizers":[]}}' --type=merge
then
  kubectl delete --filename hashicups/ --ignore-not-found=true --grace-period=5 --wait=false
else
  exit 1
fi