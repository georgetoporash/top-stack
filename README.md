# exec next command to deploy k8s cluster on Ubuntu 22.04

## worker node:
    /bin/bash ./common_k8s_node.sh <worker ip> k8smaster.example.net worker 

## master node:
    /bin/bash ./common_k8s_node.sh <master ip> k8smaster.example.net master
