# Abstract
This project allows to setup a Hadoop mini cluster on a VirtualBox machine using vagrant.

[Apache Ambari QS guide](https://cwiki.apache.org/confluence/display/AMBARI/Quick+Start+Guide)

Ambari is now running on http://c7401.ambari.apache.org:8080 

# Store Data in Hadoop
connect to the ambri server 
http://c7401.ambari.apache.org:8080

Find out about the HDP cluster at HDFS/Configs/Advanced/NameNode/NameNode host

```bash
vagrant ssh c7402
sudo su - hdfs
hadoop fs -put text_c7402.txt hdfs://c7402.ambari.apache.org:8020/text_c7402.txt
```

Then log in from another node to test the file is in HDP.
```bash
vagrant ssh c7404
sudo su - hdfs
[hdfs@c7403 ~]$ hadoop fs -get hdfs://c7402.ambari.apache.org/text_c7402.txt ~/text_c7402.txt && cat ~/text_c7402.txt
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