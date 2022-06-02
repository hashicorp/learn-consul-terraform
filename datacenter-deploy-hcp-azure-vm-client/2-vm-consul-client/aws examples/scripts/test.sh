HVN_CIDR="172.25.32.0/20"
RESOURCE_GROUP_NAME=learn-hcp-consul-vm-client-gid
SECURITY_GROUP_ID=learn-hcp-consul-vm-client-nsg

# Create inbound rules
az network nsg rule create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --nsg-name "$SECURITY_GROUP_ID" \
    --name ConsulServerInbound \
    --priority 400 \
    --source-address-prefixes "$HVN_CIDR" \
    --destination-address-prefixes VirtualNetwork \
    --destination-port-ranges 8301 \
    --direction Inbound \
    --access Allow

az network nsg rule create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --nsg-name "$SECURITY_GROUP_ID" \
    --name ConsulClientInbound \
    --priority 401 \
    --source-address-prefixes VirtualNetwork \
    --destination-address-prefixes VirtualNetwork \
    --destination-port-ranges 8301 \
    --direction Inbound \
    --access Allow

#Create outbound rules
az network nsg rule create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --nsg-name "$SECURITY_GROUP_ID" \
    --name ConsulServerOutbound \
    --priority 400 \
    --source-address-prefixes VirtualNetwork \
    --destination-address-prefixes "$HVN_CIDR" \
    --destination-port-ranges "8300-8301" \
    --direction Outbound \
    --access Allow

az network nsg rule create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --nsg-name "$SECURITY_GROUP_ID" \
    --name ConsulClientOutbound \
    --priority 401 \
    --source-address-prefixes VirtualNetwork \
    --destination-address-prefixes VirtualNetwork \
    --destination-port-ranges 8301 \
    --direction Outbound \
    --access Allow

az network nsg rule create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --nsg-name "$SECURITY_GROUP_ID" \
    --name HTTPOutbound \
    --priority 402 \
    --source-address-prefixes VirtualNetwork \
    --destination-address-prefixes "$HVN_CIDR" \
    --destination-port-ranges 80 \
    --direction Outbound \
    --access Allow

az network nsg rule create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --nsg-name "$SECURITY_GROUP_ID" \
    --name HTTPSOutbound \
    --priority 403 \
    --source-address-prefixes VirtualNetwork \
    --destination-address-prefixes "$HVN_CIDR" \
    --destination-port-ranges 443 \
    --direction Outbound \
    --access Allow