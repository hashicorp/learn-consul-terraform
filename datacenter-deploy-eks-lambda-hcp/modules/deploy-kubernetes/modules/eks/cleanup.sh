#!/usr/bin/env bash

# Lookup kube crds
CRD_EXISTS=$(kubectl get ${SERVICETYPE} ${SERVICENAME})

echo "${CRD_EXISTS}"
# delete the crds
if [[ $CRD_EXISTS ]]
then
  # patch cr
  echo "kubectl patch ${SERVICETYPE} ${SERVICENAME} -p '{\"metadata\":{\"finalizers\":[]}}' --type=merge"
  kubectl patch "${SERVICETYPE}" "${SERVICENAME}" -p '{"metadata":{"finalizers":[]}}' --type=merge
  echo $?
  kubectl get "${SERVICETYPE}" "${SERVICENAME}" -o yaml | grep -i "finalizers"
  echo "deleting crd"

  kubectl delete "${SERVICETYPE}" "${SERVICENAME}" --ignore-not-found=true
fi
# delete the crds again
if [[ $CRD_EXISTS ]]
then
  echo "deleting crd again"
  kubectl delete "${SERVICETYPE}" "${SERVICENAME}" --ignore-not-found=true
fi
