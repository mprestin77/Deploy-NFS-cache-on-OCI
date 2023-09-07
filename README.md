# Deploy NFS cache on OCI

### Introduction
This setup gives your cloud-based compute instances access to on-prem NFS storage by caching data on cloud when an NFS client requests it. NFS client nodes write data directly back to your NFS origin file server using write-through caching. 

### Architecture
NFS cache can be deployed in number of different architectures. In this example I am using the following architecture

![image](https://github.com/mprestin77/Deploy-NFS-cache-on-OCI/assets/54962742/f762f23b-dfe9-4598-8d3e-8be116e5df06)

For HA purpose you can install a Network Load balancer (NLB) with 2 or more backend NFS cache servers and configure TCP/2049 port in NLB listener

![image](https://github.com/mprestin77/Deploy-NFS-cache-on-OCI/assets/54962742/a8681e27-4450-4baa-a81b-f438381cb181)

### Deployment
To deploy NFS cache on OCI provision an Oracle Linux compute instance using one of E4.DenseIO.Flex shapes

![image](https://github.com/mprestin77/Deploy-NFS-cache-on-OCI/assets/54962742/452b83cb-554a-47f9-a6b1-c177ff045096)

These DenseIO shapes have different number of NVMe local disks. NVMe storage will be used for caching NFS data. Select the shape based on the storage requirements.

Select VCN and subnet, add public SSH key and then open Advanced Options and add Cloud-init script install.sh from the github

![image](https://github.com/mprestin77/Deploy-NFS-cache-on-OCI/assets/54962742/9abb58e3-645f-4722-9f81-d88b2573acbb)

The script does the following:

1. Configures RAID-0 on available NVMe disks
2. Creates a filesystem on RAID-0 device and mounts it 
3. Installs cachefiled package and starts cachefiled service
4. Enables NFS server
5. Configures SELinux and Linux firewall

### Post provisioning steps:

Create a directory for NFS mount point, and mount NFS Server share to NFS cache VM using -fsc option. For example,
```
sudo mount <NFS-server-IP>:/nfs-share /nfs-share -o fsc
```
Export NFS share by editing /etc/exports file 
```
sudo echo "/nfs-share *(rw,wdelay,no_root_squash,no_subtree_check,fsid=10,sec=sys,rw,secure,no_root_squash,no_all_squash)" > /etc/exports
sudo exportfs -a
```
Check that cachfiled service is running

sudo systemctl status cachefilesd

![image](https://github.com/mprestin77/Deploy-NFS-cache-on-OCI/assets/54962742/41f4b8e3-591b-40f6-8655-4d2ea0f5fbd0)

Mount directories exported from NFS cache to NFS clients. For example, on NFS client you can run
```
sudo mount <NFS-cache-IP>:/nfs-share /nfs-share 
```
When reading files that are not cached yet on FS-Cache server the access time will be longer. However, when a file is cached the read time will be comparible to accessing NFS server on the same LAN. The difference will be even more obvious when many NFS clients read the same content from the NFS share.

### Conclusion
NFS performance is very sensitive to network latency. Even a relatively small network latency can significantly degrade NFS performance for both reads and writes. When using on-prem NFS storage deploying NFS cache on cloud can lead to significant performance benefits, particularly for "read-heavy" workloads. 



