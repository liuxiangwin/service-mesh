#!/bin/sh
SERVICE_MESH="istio-system"
USERS="user1 user2 user3 user4 user5"
for user in ${USERS}
do
    oc new-project $user --display-name="$user Project"
    oc adm policy add-role-to-user admin $user -n $user
done
for user in ${USERS}
do
    oc adm policy add-role-to-user admin $user -n $SERVICE_MESH
    oc adm policy add-role-to-user kiali-viewer $user -n $SERVICE_MESH
    oc adm policy add-role-to-user monitoringdashboards.monitoring.kiali.io-v1alpha1-admin $user $SERVICE_MESH
    oc adm policy add-cluster-role-to-user view $user
done
