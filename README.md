# Abstract
This project allows to setup a Hadoop mini cluster on a VirtualBox machine using vagrant.

[Apache Ambari QS guide](https://cwiki.apache.org/confluence/display/AMBARI/Quick+Start+Guide)
Use centos7.4 when starting virtual boxes with the ./up.sh script.

https://docs.hortonworks.com/HDPDocuments/Ambari/Ambari-2.7.1.0/index.html
https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.1.0/administering-ambari/content/amb_install_the_new_ambari_server.html

Ambari is now running on http://c7401.ambari.apache.org:8080 

wget -O /etc/yum.repos.d/ambari.repo http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari.repo
yum install ambari-server -y


# Store Data in Hadoop
connect to the ambri server 
http://c7401.ambari.apache.org:8080

Find out about the HDP cluster at HDFS/Configs/Advanced/NameNode/NameNode host

```bash
cd ambari-vagrant/centos7.4/
vagrant ssh c7402
sudo su - hdfs
hadoop fs -put c7401.txt hdfs://c7401.ambari.apache.org:8020/c7401.txt
```

Then log in from another node to test the file is in HDP.
```bash
vagrant ssh c7404
sudo su - hdfs
[hdfs@c7403 ~]$ hadoop fs -get hdfs://c7401.ambari.apache.org/c7401.txt ~/c7401.txt && cat ~/c7401.txt
Coucou from text_c7402.txt
[hdfs@c7403 ~]$
```

Check the HDFS
```bash
[hdfs@c7403 ~]$ hadoop fs -count -v -t -h hdfs://c7402.ambari.apache.org/
   DIR_COUNT   FILE_COUNT       CONTENT_SIZE PATHNAME
          33           16            248.2 M hdfs://c7402.ambari.apache.org/
[hdfs@c7403 ~]$ hadoop fs -ls -h hdfs://c7402.ambari.apache.org:8020/
Found 11 items
drwxrwxrwx   - yarn   hadoop          0 2018-11-06 11:07 hdfs://c7402.ambari.apache.org/app-logs
drwxr-xr-x   - yarn   hadoop          0 2018-11-06 11:03 hdfs://c7402.ambari.apache.org/ats
-rw-r--r--   3 hdfs   hdfs            7 2018-11-06 14:29 hdfs://c7402.ambari.apache.org/example1
-rw-r--r--   3 hdfs   hdfs            7 2018-11-06 14:35 hdfs://c7402.ambari.apache.org/example2
drwxr-xr-x   - hdfs   hdfs            0 2018-11-06 11:03 hdfs://c7402.ambari.apache.org/hdp
drwxr-xr-x   - mapred hdfs            0 2018-11-06 11:03 hdfs://c7402.ambari.apache.org/mapred
drwxrwxrwx   - mapred hadoop          0 2018-11-06 11:04 hdfs://c7402.ambari.apache.org/mr-history
-rw-r--r--   3 hdfs   hdfs           27 2018-11-06 14:46 hdfs://c7402.ambari.apache.org/text_c7402.txt
-rw-r--r--   3 hdfs   hdfs           27 2018-11-06 14:41 hdfs://c7402.ambari.apache.org/text_c7404.txt
drwxrwxrwx   - hdfs   hdfs            0 2018-11-06 11:04 hdfs://c7402.ambari.apache.org/tmp
drwxr-xr-x   - hdfs   hdfs            0 2018-11-06 11:03 hdfs://c7402.ambari.apache.org/user
[hdfs@c7403 ~]$ 
```

# Restart a node
The ambari-agent may not be able to connect to the name node.
in the /etc/ambari-agent/conf/ambari-agent.ini one must add this in the [security] section.
force_https_protocol=PROTOCOL_TLSv1_2

For instance.
```bash
[security]
keysdir=/var/lib/ambari-agent/keys
server_crt=ca.crt
passphrase_env_var_name=AMBARI_PASSPHRASE
ssl_verify_cert=0
credential_lib_dir=/var/lib/ambari-agent/cred/lib
credential_conf_dir=/var/lib/ambari-agent/cred/conf
credential_shell_cmd=org.apache.hadoop.security.alias.CredentialShell
force_https_protocol=PROTOCOL_TLSv1_2
```

# REST API to force removal of a node
https://cwiki.apache.org/confluence/display/AMBARI/Using+APIs+to+delete+a+service+or+all+host+components+on+a+host

## Check the hosts with Ambari API
```bash
curl -u admin:admin -H "X-Requested-By: ambari" -X GET  http://c7401.ambari.apache.org:8080/api/v1/hosts
```

## Check one particular host
```bash
curl -u admin:admin -H "X-Requested-By: ambari" -X GET  http://c7401.ambari.apache.org:8080/api/v1/clusters/macos_cluster/hosts/c7410.ambari.apache.org
```

## Stop all components of a specific host
```bash
for i in `curl -u admin:admin -H "X-Requested-By: ambari" -X GET  http://c7401.ambari.apache.org:8080/api/v1/clusters/macos_cluster/hosts/c7410.ambari.apache.org | grep component_name | cut -d : -f 2 | cut -d \" -f 2` ; do \
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Component"},"Body":{"HostRoles":{"state":"INSTALLED"}}}' http://c7401.ambari.apache.org:8080/api/v1/clusters/macos_cluster/hosts/c7410.ambari.apache.org/host_components/ ;
done
```

## Remove all components mapped to the host to remove
```bash
for i in `curl -u admin:admin -H "X-Requested-By: ambari" -X GET  http://c7401.ambari.apache.org:8080/api/v1/clusters/macos_cluster/hosts/c7410.ambari.apache.org | grep component_name | cut -d : -f 2 | cut -d \" -f 2` ; do \
curl -u admin:admin -H "X-Requested-By: ambari" -X DELETE http://c7401.ambari.apache.org:8080/api/v1/clusters/macos_cluster/hosts/c7410.ambari.apache.org/host_components/$i; \
done
```

## Remove the host
```bash
curl -u admin:admin -H "X-Requested-By: ambari" -X DELETE http://c7401.ambari.apache.org:8080/api/v1/clusters/macos_cluster/hosts/c7410.ambari.apache.org
```

# Add a Node pseudo-manually with Ambari
https://cwiki.apache.org/confluence/display/AMBARI/Add+a+host+and+deploy+components+using+APIs

2.5.1.0
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari.repo -O /etc/yum.repos.d/ambari.repo

2.6.2.0
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.6.2.0/ambari.repo -O /etc/yum.repos.d/ambari.repo

Don't forget to install the same version as the ambari server.
yum install -y ambari-agent-2.5.1.0

Check the host
curl -u admin:admin -H "X-Requested-By: ambari" -X GET  http://c7401.ambari.apache.org:8080/api/v1/hosts

# Hadoop NameNode SafeMode

[hdfs@c7401 ~]$ hdfs dfsadmin -safemode get
Safe mode is OFF
[hdfs@c7401 ~]$ hdfs dfsadmin -safemode leave
Safe mode is OFF
[hdfs@c7401 ~]$ 
