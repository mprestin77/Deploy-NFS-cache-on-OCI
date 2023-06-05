# Deploy NFS cache on OCI

NFS cache can be deployed in 2 architectures

### Architectural diagram1 (used in the article)

![image](https://github.com/mprestin77/Deploy-NFS-cache-on-OCI/assets/54962742/f762f23b-dfe9-4598-8d3e-8be116e5df06)

### Architectural diagram2 (can be configured for HA)

![image](https://github.com/mprestin77/Deploy-NFS-cache-on-OCI/assets/54962742/a8681e27-4450-4baa-a81b-f438381cb181)

To deploy NFS cache on OCI provision a compute instance using one of E4.DenseIO.Flex shape. Use of one available E4.DenseIO.Flex shapes available

![image](https://github.com/mprestin77/Deploy-NFS-cache-on-OCI/assets/54962742/452b83cb-554a-47f9-a6b1-c177ff045096)

These DenseIO shapes have different number of NVMe local disks. NVMe storage will be used for caching NFS data. Select the shape based on the storage requirements.

Select VCN and subnet, add public SSH key and then open Advanced Options and add Cloud-init script install.sh from the github

![image](https://github.com/mprestin77/fs-cache/assets/54962742/2dadf357-e3ef-4db0-a4e5-6aa2ce44a86a)


The script does the following:

1. Configures RAID-0 on available NVMe disks
2. Creates a filesystem on RAID-0 device and mounts it 
3. Installs cachefiled package and starts cachefiled service
4. Enables NFS server
5. Configures SELinux and Linux firewall

### Post provisioning steps:

Create a directory for NFS mount point, and mount NFS Server share to NFS cache VM using -fsc option. For example,

sudo mount <NFS-server-IP:/nfs-share /nfs-share -o fsc

Export NFS share by editing /etc/exports file 

sudo echo "/nfs-share *(rw,wdelay,no_root_squash,no_subtree_check,fsid=10,sec=sys,rw,secure,no_root_squash,no_all_squash)" > /etc/exports

sudo exportfs -a

Check the cachfiled service is running

sudo systemctl status cachefiled

![image](https://github.com/mprestin77/fs-cache/assets/54962742/9d4cb01b-b5ca-4ec1-aa46-2bf1cb06d338)

Mount directories exported from NFS cache to NFS clients. For example, on NFS client you can run

sudo mount <NFS-cache-IP:/nfs-share /nfs-share 





