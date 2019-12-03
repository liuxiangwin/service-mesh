#!/bin/sh
oc delete -f ocp/backend-v1-deployment.yml
oc delete -f ocp/backend-v2-deployment.yml
oc delete -f ocp/backend-service.yml
oc delete -f ocp/frontend-v1-deployment.yml
oc delete -f ocp/frontend-v2-deployment.yml
oc delete -f ocp/frontend-service.yml
oc delete -f ocp/frontend-route.yml
