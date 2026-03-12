#!/bin/bash

CLUSTER_NAME="nginx-cluster"
REGION="ap-south-1"

echo "------------------------------------"
echo "Starting Kubernetes cleanup"
echo "------------------------------------"

echo "Deleting nginx service..."
kubectl delete service nginx --ignore-not-found

echo "Deleting nginx deployment..."
kubectl delete deployment nginx --ignore-not-found

echo "Waiting for AWS LoadBalancer to terminate..."
sleep 30

echo "------------------------------------"
echo "Deleting EKS cluster"
echo "------------------------------------"

eksctl delete cluster \
--name $CLUSTER_NAME \
--region $REGION

echo "------------------------------------"
echo "Cleanup completed"
echo "------------------------------------"
