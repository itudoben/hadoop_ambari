#!/bin/bash
# This script allows one to check an Ambari host and delete all components.

usage() {
    echo $0: hostname
}

hostname=$1.ambari.apache.org

AMS_HOST=c7401.ambari.apache.org
# curl -u admin:admin -H "X-Requested-By: ambari" -X GET  http://${AMS_HOST}:8080/api/v1/hosts

#curl -u admin:admin -H "X-Requested-By: ambari" -X GET  http://${AMS_HOST}:8080/api/v1/clusters/macos_cluster/hosts/${hostname} > /dev/null 2>&1

component_names=$(curl -u admin:admin -H "X-Requested-By: ambari" -X GET  http://${AMS_HOST}:8080/api/v1/clusters/macos_cluster/hosts/${hostname} | grep component_name | cut -d : -f 2 | cut -d \" -f 2)

echo ${component_names}

# Component to keep
components_to_keep=()
#components_to_keep=("HDFS_CLIENT" "METRICS_COLLECTOR" "METRICS_GRAFANA" "METRICS_MONITOR" "NAMENODE" "ZOOKEEPER_SERVER")
# "DATANODE" "HDFS_CLIENT" "YARN_CLIENT" "MAPREDUCE2_CLIENT" "METRICS_COLLECTOR" "METRICS_GRAFANA" "METRICS_MONITOR" "NAMENODE" "NODEMANAGER" "YARN_CLIENT" "ZOOKEEPER_CLIENT" "ZOOKEEPER_SERVER"
# "HDFS_CLIENT" "METRICS_COLLECTOR" "METRICS_GRAFANA" "METRICS_MONITOR" "NAMENODE" "NODEMANAGER" "ZOOKEEPER_SERVER"
# HST_AGENT HST_SERVER   ZOOKEEPER_SERVER

# exit 1

for i in ${component_names[@]}; do
    # Component name
    cpt_name=${i//[[:space:]]/}

    is_component_to_keep=0
    for ctk in ${components_to_keep[@]}; do
        if [ "${cpt_name}" == "${ctk}" ]; then
            is_component_to_keep=1
            break
        fi
    done

    echo ${is_component_to_keep}
    if [ "0" -eq "${is_component_to_keep}" ]; then
        echo "Stopping ${i} from running on ${hostname}"
        curl -u admin:admin -H "X-Requested-By: ambari" -X PUT \
            -d '{"RequestInfo":{"context":"Stop Component"},"Body":{"HostRoles":{"state":"INSTALLED"}}}' \
            http://${AMS_HOST}:8080/api/v1/clusters/macos_cluster/hosts/${hostname}/host_components/${cpt_name} ;

#        echo "Delete component ${cpt_name}"
#        curl -u admin:admin -H "X-Requested-By: ambari" -X DELETE \
#            http://${AMS_HOST}:8080/api/v1/clusters/macos_cluster/hosts/${hostname}/host_components/${cpt_name}; \
    else
        echo "Keeping ${cpt_name} running"
    fi

done

# Remove the host
# curl -u admin:admin -H "X-Requested-By: ambari" -X DELETE http://${AMS_HOST}:8080/api/v1/clusters/macos_cluster/hosts/${hostname}

exit 0