# Deploy NFS cache proxy on OCI

NFS cache can be deploy in 2 architectures

### Architecture1

![image](https://github.com/mprestin77/fs-cache/assets/54962742/e0f6d554-8dff-42e3-9c9e-62d2d8402369)


### Architecture2
![image](https://github.com/mprestin77/fs-cache/assets/54962742/3edabc1c-7891-480c-88ab-354e6bca2b3b)


To deploy NFS cache on OCI provision a compute instance using one of E4.DenseIO.Flex shape. 

![image](https://github.com/mprestin77/fs-cache/assets/54962742/ce6780af-2b9e-4150-995d-9c847848829d)

Use of one available E4.DenseIO.Flex shapes available

![image](https://github.com/mprestin77/fs-cache/assets/54962742/2a602cc6-1733-4ccf-a3b3-2b14f461c894)

These DenseIO shapes have different number of NVMe local disks. NVMe storage will be used for caching NFS data. Select the shape based on the storage requirements.






