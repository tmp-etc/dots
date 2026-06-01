#!/bin/bash

doctl compute droplet create \
    --image 228148100 \
    --size s-1vcpu-2gb \
    --region nyc1 \
    --tag-names '' \
    --ssh-keys '56507237' \
    dc
