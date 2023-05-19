# Deploy NFS cache on OCI

NFS cache can be deploy in 2 architectures

### Architectural diagram1 (used in the article)

![image](https://github.com/mprestin77/fs-cache/assets/54962742/e0f6d554-8dff-42e3-9c9e-62d2d8402369)


### Architectural diagram2 (can be configured for HA)

![image](https://github.com/mprestin77/fs-cache/assets/54962742/3edabc1c-7891-480c-88ab-354e6bca2b3b)

To deploy NFS cache on OCI provision a compute instance using one of E4.DenseIO.Flex shape. 

![image](https://github.com/mprestin77/fs-cache/assets/54962742/ce6780af-2b9e-4150-995d-9c847848829d)

Use of one available E4.DenseIO.Flex shapes available

![image](https://github.com/mprestin77/fs-cache/assets/54962742/2a602cc6-1733-4ccf-a3b3-2b14f461c894)

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

Mount NFS server directory to NFS cache VM using -fsc option




