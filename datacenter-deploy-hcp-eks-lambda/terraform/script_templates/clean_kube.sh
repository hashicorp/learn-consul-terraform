#!/usr/bin/env bash

#aws_region=$1
#cluster_name=$2

#aws eks --region "${aws_region}" update-kubeconfig --name "${cluster_name}" --alias "${cluster_name}"
kubectl get gatewayclasses      --ignore-not-found=true | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch gatewayclasses {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get gatewayclassconfigs --ignore-not-found=true | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch gatewayclassconfigs {} -p '{"metadata":{"finalizers":[]}}' --type=merge

kubectl get servicesplitters    --ignore-not-found=true | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch servicesplitters {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get terminatinggateways --ignore-not-found=true | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch terminatinggateways {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get serviceintentions   --ignore-not-found=true | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch serviceintentions {} -p '{"metadata":{"finalizers":[]}}' --type=merge


kubectl delete --filename ../service_splitter.yaml --ignore-not-found=true --grace-period=5 --wait=false
kubectl delete --filename ../terminating-gateway.yaml --ignore-not-found=true --grace-period=5 --wait=false
kubectl delete --filename ../api-gw/routes.yaml --ignore-not-found=true --grace-period=5 --wait=false
kubectl delete --filename ../api-gw/consul-api-gateway.yaml --ignore-not-found=true --grace-period=5 --wait=false
kubectl delete --filename ../hashicups --ignore-not-found=true --grace-period=5 --wait=false

echo "All resources removed. Terraform will now continue..."
