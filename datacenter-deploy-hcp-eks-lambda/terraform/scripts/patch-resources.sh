#!/usr/bin/env bash

cd $$(dirname $0)

echo "    ===      "
echo "  PATCHING   "
echo "    ===      "

  kubectl get gateways --ignore-not-found=true | awk '{print $$1}' | grep -v NAME | xargs -I {} kubectl patch gateways {} -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl get servicedefaults --ignore-not-found=true | awk '{print $$1}' | grep -v NAME | xargs -I {} kubectl patch servicedefaults {} -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl get servicesplitters --ignore-not-found=true | awk '{print $$1}' | grep -v NAME | xargs -I {} kubectl patch servicesplitters {} -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl get terminatinggateways --ignore-not-found=true | awk '{print $$1}' | grep -v NAME | xargs -I {} kubectl patch terminatinggateways {} -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl get serviceintentions --ignore-not-found=true | awk '{print $$1}' | grep -v NAME | xargs -I {} kubectl patch serviceintentions {} -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl get gatewayclasses --ignore-not-found=true | awk '{print $$1}' | grep -v NAME | xargs -I {} kubectl patch gatewayclasses {} -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl get gatewayclassconfigs --ignore-not-found=true | awk '{print $$1}' | grep -v NAME | xargs -I {} kubectl patch gatewayclassconfigs {} -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl get proxydefaults --ignore-not-found=true | awk '{print $$1}' | grep -v NAME | xargs -I {} kubectl patch proxydefaults {} -p '{"metadata":{"finalizers":[]}}' --type=merge



#kubectl get gateways            --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch gateways {} -p '{"metadata":{"finalizers":[]}}' --type=merge
#kubectl get servicedefaults     --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch servicedefaults {} -p '{"metadata":{"finalizers":[]}}' --type=merge
#kubectl get servicesplitters    --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch servicesplitters {} -p '{"metadata":{"finalizers":[]}}' --type=merge
#kubectl get terminatinggateways --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch terminatinggateways {} -p '{"metadata":{"finalizers":[]}}' --type=merge
#kubectl get serviceintentions   --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch serviceintentions {} -p '{"metadata":{"finalizers":[]}}' --type=merge
#kubectl get gatewayclasses      --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch gatewayclasses {} -p '{"metadata":{"finalizers":[]}}' --type=merge
#kubectl get gatewayclassconfigs --ignore-not-found=true | awk '{print $1}' | grep -v NAME | xargs -I {} kubectl patch gatewayclassconfigs {} -p '{"metadata":{"finalizers":[]}}' --type=merge

#kubectl delete --filename ../rendered/service_splitter.yaml --ignore-not-found=true --grace-period=5 --wait=false
#kubectl delete --filename ../rendered/terminating-gateway.yaml --ignore-not-found=true --grace-period=5 --wait=false
#kubectl delete --filename ../rendered/service-splitter.yaml --ignore-not-found=true --grace-period=5 --wait=false


echo "    ===      "
echo "  DELETING   "
echo "    ===      "

  kubectl delete --filename ./practitioner/service-intentions.yaml  --ignore-not-found=true --grace-period=5 --wait=false
  kubectl delete --filename ./practitioner/service-splitter.yaml  --ignore-not-found=true --grace-period=5 --wait=false
  kubectl delete --filename ./practitioner/terminating-gateway.yaml  --ignore-not-found=true --grace-period=5 --wait=false
