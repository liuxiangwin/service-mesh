#!/bin/sh
oc delete -f istio-files/authentication-backend-enable-mtls.yml
oc delete -f istio-files/authentication-frontend-enable-mtls.yml
oc delete -f istio-files/destination-rule-backend-circuit-breaker-with-pool-ejection.yml
oc delete -f istio-files/destination-rule-backend-v1-v2-mtls.yml
oc delete -f istio-files/destination-rule-backend-v1-v2.yml
oc delete -f istio-files/destination-rule-frontend-mtls.yml
oc delete -f istio-files/destination-rule-frontend-v1-v2.mtls.yml
oc delete -f istio-files/destination-rule-frontend-v1-v2.yml
oc delete -f istio-files/frontend-gateway.yml
oc delete -f istio-files/virtual-service-backend-v1-v2-50-50-3s-timeout.yml
oc delete -f istio-files/virtual-service-backend-v1-v2-50-50.yml
oc delete -f istio-files/virtual-service-backend-v1-v2-80-20.yml
oc delete -f istio-files/virtual-service-backend-v1-v2-mirror-to-v3.yml
oc delete -f istio-files/virtual-service-backend.yml	
oc delete -f istio-files/virtual-service-frontend-header-foo-bar-to-v1.yml
oc delete -f istio-files/virtual-service-frontend.yml

oc delete -f ocp/backend-v1-deployment.yml
oc delete -f ocp/backend-v2-deployment.yml
oc delete -f ocp/backend-v3-deployment.yml
oc delete -f ocp/backend-service.yml
oc delete -f ocp/backend-v3-service.yml
oc delete -f ocp/frontend-v1-deployment.yml
oc delete -f ocp/frontend-v2-deployment.yml
oc delete -f ocp/frontend-service.yml
oc delete -f ocp/frontend-route.yml
oc delete -f ocp/station-deployment.yml
