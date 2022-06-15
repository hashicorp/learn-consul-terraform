#!/usr/bin/env bash

SERVICENAME=$2

SERVICETYPE=$3

# Lookup kube crds
CRD_EXISTS=$(kubectl get ${SERVICETYPE} ${SERVICENAME})

# delete the crds
if [[ $CRD_EXISTS ]]
then
  # patch crd
  kubectl patch "${SERVICETYPE}" "${SERVICENAME}" -p '{"metadata":{"finalizers":[]}}' --type=merge
  echo "deleting crd"
  kubectl delete "${SERVICETYPE}" "${SERVICENAME}" --ignore-not-found=true
fi
# delete the crds again
if [[ $CRD_EXISTS ]]
then
  echo "deleting crd again"
  kubectl delete "${SERVICETYPE}" "${SERVICENAME}" --ignore-not-found=true
fi
