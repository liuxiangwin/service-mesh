#!/bin/sh
oc apply -f ocp/backend-v1-deployment.yml
oc apply -f ocp/backend-v2-deployment.yml
oc apply -f ocp/backend-service.yml
oc apply -f ocp/frontend-v1-deployment.yml
#oc apply -f ocp/frontend-v2-deployment.yml
oc apply -f ocp/frontend-service.yml
oc apply -f ocp/frontend-route.yml
