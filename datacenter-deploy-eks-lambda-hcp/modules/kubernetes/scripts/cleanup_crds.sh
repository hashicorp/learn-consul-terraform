#!/usr/bin/env bash

# Remove CRDs objects that are not managed by consul-k8s, otherwise terraform destroy deadlocks
kubectl get serviceintentions | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch serviceintentions {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get servicesplitters| awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch servicesplitters {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get terminatinggateways| awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch terminatinggateways {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get serviceresolvers | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch serviceresolvers {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get proxydefaults | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch proxydefaults {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get gatewayclasses | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch gatewayclasses {} -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get gatewayclassconfigs | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl patch gatewayclassconfigs {} -p '{"metadata":{"finalizers":[]}}' --type=merge



