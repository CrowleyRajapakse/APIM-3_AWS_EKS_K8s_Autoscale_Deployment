# API Manager 3.0 AWS EKS EFS ECR K8s AutoScale Deployment
Deploying API Manager 3.0 in a k8s cluster in AWS EKS with hpa and sharing synapse configs with AWS EFS(NFS) volume mount.

## Setup EKS CLuster
You can follow the following full guide to setup a AWS EKS Cluster.

[Getting Started with Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html)

We are providing following major steps for your reference.

### 1. Install AWS CLI

To install or upgrade the AWS CLI, follow [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

You can check your AWS CLI version with the following command:

```sh
>> aws --version
```

### 2. Configure Kubectl with the EKS cluster

Use the AWS CLI command: [update-kubeconfig](https://docs.aws.amazon.com/cli/latest/reference/eks/update-kubeconfig.html) to configure the `kubectl` so that you can connect to an Amazon EKS cluster. 

```sh
>> aws eks --region region update-kubeconfig --name cluster_name
```

For the following case it is `JLR_APIM` and configure `kubectl` as follows.

![Amazon EKS cluster](images/aws-eks-cluster.png)

```sh
>> aws eks --region us-east-2 update-kubeconfig --name JLR_APIM
```

Test your configuration.
```sh
>> kubectl get svc
```

Output:
```sh
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   1m
```

Verify that you have running Node Groups with following command. Otherwise launch a [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html).
```sh
>> kubectl get nodes
```

Output:
```sh
NAME                                          STATUS   ROLES    AGE   VERSION
ip-172-31-24-135.us-east-2.compute.internal   Ready    <none>   6d    v1.14.8-eks-b8860f
ip-172-31-3-184.us-east-2.compute.internal    Ready    <none>   6d    v1.14.8-eks-b8860f
```

Here, when setting up the EKS Cluster earlier following node group configurations were used.

- Minimum size: 2 nodes
- Maximum size: 3 nodes
- Desired size: 2 nodes

Therefore, by normal at least two nodes are active at all time.

![Node Group](images/node-group.png)

### 3. Create an Amazon EFS storage for NFS.

You can use Amazon EFS to mount the synapse configs. Following doc [Create EFS storage](https://docs.aws.amazon.com/efs/latest/ug/getting-started.html)

![Amazon EFS repo](images/efs-storage.png)

## Deploy API Manager 3.0.0 optimized as a gateway-worker in EKS

- Configure the .yaml files in the /configured directory accordingly.
- Execute the following command to setup the gateway deployement.
```sh
>> kubectl apply -f configured/
```
Output:
```sh
horizontalpodautoscaler.autoscaling/wso2apim created
storageclass.storage.k8s.io/aws-efs created
configmap/efs-provisioner created
namespace/wso2 created
configmap/apim-conf created
deployment.apps/wso2apim created
persistentvolumeclaim/gateway-shared-synapse-configs-volume-claim created
persistentvolume/gateway-shared-synapse-configs-volume created
service/wso2apim created
```

You can see a sample deployment information in the following image.

![Sample Infp](images/sample-info.png)

Here, you can see the following autoscaling policy applied
```sh
NAME               REFERENCE                 TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
petstore-api-hpa   Deployment/petstore-api   <unknown>/50%   1         5         1          5d19h
wso2apim           Deployment/wso2apim       <unknown>/50%   1         10        1          6d
```
Therefore, if the CPU Utilization of a pod exceeds 50% deployment will scale the pods up to maximum of 10 pods.

Please note the "wso2apim" is the deployment of the normal WSO2 API Manager Gateway. The deployment named in the image "petstore-api" is a WSO2 API Microgateway deployment using WSO2 APIM K8s operator. 
You can deploy the MG deployment in AWS EKS by following this guide [Microgateway Deployment in AWS EKS](https://github.com/wso2/K8s-api-operator/blob/master/docs/HowToGuide/working-with-aws.md).

## Try out

Execute following command to view the server logs.
```sh
>> kubectl logs <POD_ID> -n wso2
```

- You can access the gateway using the external ip provided by the LB.

- [x] US Backend

```sh
>> curl -X GET "http://a9638b7556d9711eaa663064b99b1f5c-1286476463.us-east-2.elb.amazonaws.com:8080/entities/vehicles/25" -H "accept: application/json" -k
```

- [x] US Synapse Gateway

```sh
>> curl -X GET "https://ad998945664e011eabf900aa2059d57f-933146450.us-east-2.elb.amazonaws.com:30801/petstore/v1/v1/pet/5" -H  "accept: application/xml" -H  "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik9UZ3pPRE0wTlRVMU1EQTVPVFppWTJFM1ptUmlOVFpsWkRVek9UUTNZMk0yWW1VeFlqVmtOQT09In0.eyJhdWQiOiJodHRwOlwvXC9vcmcud3NvMi5hcGltZ3RcL2dhdGV3YXkiLCJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhcHBsaWNhdGlvbiI6eyJvd25lciI6ImFkbWluIiwidGllciI6IlVubGltaXRlZCIsIm5hbWUiOiJUZXN0SldUIiwiaWQiOjUsInV1aWQiOm51bGx9LCJzY29wZSI6ImFtX2FwcGxpY2F0aW9uX3Njb3BlIGRlZmF1bHQiLCJpc3MiOiJodHRwczpcL1wvMzUuMjI4LjIxOC4xNzY6OTQ0M1wvb2F1dGgyXC90b2tlbiIsInRpZXJJbmZvIjp7IlVubGltaXRlZCI6eyJzdG9wT25RdW90YVJlYWNoIjp0cnVlLCJzcGlrZUFycmVzdExpbWl0IjowLCJzcGlrZUFycmVzdFVuaXQiOm51bGx9fSwia2V5dHlwZSI6IlBST0RVQ1RJT04iLCJzdWJzY3JpYmVkQVBJcyI6W3sic3Vic2NyaWJlclRlbmFudERvbWFpbiI6ImNhcmJvbi5zdXBlciIsIm5hbWUiOiJQZXRzdG9yZS1BUEkiLCJjb250ZXh0IjoiXC9wZXRzdG9yZVwvdjFcL3YxIiwicHVibGlzaGVyIjoiYWRtaW4iLCJ2ZXJzaW9uIjoidjEiLCJzdWJzY3JpcHRpb25UaWVyIjoiVW5saW1pdGVkIn0seyJzdWJzY3JpYmVyVGVuYW50RG9tYWluIjoiY2FyYm9uLnN1cGVyIiwibmFtZSI6IlBldHN0b3JlLUp3dCIsImNvbnRleHQiOiJcL3BldHN0b3Jland0XC92MSIsInB1Ymxpc2hlciI6ImFkbWluIiwidmVyc2lvbiI6InYxIiwic3Vic2NyaXB0aW9uVGllciI6IlVubGltaXRlZCJ9XSwiY29uc3VtZXJLZXkiOiJINldibkFlQUg2WE1nR3VmSFNLejI0X016V2thIiwiZXhwIjoxNTg1MDM2NjYwLCJpYXQiOjE1ODUwMzMwNjAsImp0aSI6IjlmYWVlMjU4LTg0YjEtNDJhMS1iMzJlLTc5NjAwZmFkNmQ0NCJ9.qxmYZPOjF6NaM9zto8Gz--q1lvVZ0v_Y3sU0zUg2k6O_3peE2O3Qx_E5cSNoxlVaH_Tkec80D9WImULwd2n3jftcd3FZ7gDddaut9PKTX9VDvRAsgKZ4seHl6kIO9khUw_cEsVhdgTmQNA7XpbDTaiUwgiaMbHihg_8FGpH9Ug2a8GyNppgDRcYGJ7vCeVGImb5YFGz1P7RbqiB-_UXxLFcD52gvDSUDsz0sh-iGF2bt2v-AUE1OwPQuN1nboEx042kEGTcSOHw8bEnhgbzZq57VnKTLQun3lPjl-3__OqXxN-21vhz9j7qHCfh9EO0g6N8hTYPg9HacaxHON7zw0FDWUyMnxprgSMYd4Rk4t1p15F5cupOqFthxjDmaQWZ9AeZ2H9UHBRMT_tj6Ds-MGDmDxU2jMmKjIpCZBJzA687XFYZdtwlUCPizDTjSvAoFz6ymWeu3hvjFEzU6RXmSUs9CepwCg3MtSF7LkJfuVKafiDvhozY4rsnmP-i1dpvV5dq-zj4BA-bOaFaI0oc4t2LbL_I6IxrfkJfujlHH8GdLhe7z7UathfDW_Zn70XLN9HvVEgYpqh7pAJEFR1LOP7gNtVe4NnrHGGpCvVZHBvc2LWOaqlYAvgTxupZhkkCri3Feqzypp_BQIZWwun3sUwdDGJ_pzsem0bq9dk-Nnq8" -k
```

- [x] US Microgateway

```sh
>> TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik9UZ3pPRE0wTlRVMU1EQTVPVFppWTJFM1ptUmlOVFpsWkRVek9UUTNZMk0yWW1VeFlqVmtOQT09In0.eyJhdWQiOiJodHRwOlwvXC9vcmcud3NvMi5hcGltZ3RcL2dhdGV3YXkiLCJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhcHBsaWNhdGlvbiI6eyJvd25lciI6ImFkbWluIiwidGllciI6IlVubGltaXRlZCIsIm5hbWUiOiJUZXN0SldUIiwiaWQiOjUsInV1aWQiOm51bGx9LCJzY29wZSI6ImFtX2FwcGxpY2F0aW9uX3Njb3BlIGRlZmF1bHQiLCJpc3MiOiJodHRwczpcL1wvMzUuMjI4LjIxOC4xNzY6OTQ0M1wvb2F1dGgyXC90b2tlbiIsInRpZXJJbmZvIjp7IlVubGltaXRlZCI6eyJzdG9wT25RdW90YVJlYWNoIjp0cnVlLCJzcGlrZUFycmVzdExpbWl0IjowLCJzcGlrZUFycmVzdFVuaXQiOm51bGx9fSwia2V5dHlwZSI6IlBST0RVQ1RJT04iLCJzdWJzY3JpYmVkQVBJcyI6W3sic3Vic2NyaWJlclRlbmFudERvbWFpbiI6ImNhcmJvbi5zdXBlciIsIm5hbWUiOiJQZXRzdG9yZS1BUEkiLCJjb250ZXh0IjoiXC9wZXRzdG9yZVwvdjFcL3YxIiwicHVibGlzaGVyIjoiYWRtaW4iLCJ2ZXJzaW9uIjoidjEiLCJzdWJzY3JpcHRpb25UaWVyIjoiVW5saW1pdGVkIn0seyJzdWJzY3JpYmVyVGVuYW50RG9tYWluIjoiY2FyYm9uLnN1cGVyIiwibmFtZSI6IlBldHN0b3JlLUp3dCIsImNvbnRleHQiOiJcL3BldHN0b3Jland0XC92MSIsInB1Ymxpc2hlciI6ImFkbWluIiwidmVyc2lvbiI6InYxIiwic3Vic2NyaXB0aW9uVGllciI6IlVubGltaXRlZCJ9XSwiY29uc3VtZXJLZXkiOiJINldibkFlQUg2WE1nR3VmSFNLejI0X016V2thIiwiZXhwIjoxNTg1MDM3MDI0LCJpYXQiOjE1ODUwMzM0MjQsImp0aSI6Ijc3NjAwNTJmLWY1ZjAtNGU3NS1hMTliLTM0NTc2NzA1ZGQ5NSJ9.RP-fCJw0A6IAUNf5us9h4SOGMJNFyMma-EZ58DdzjE7LH3LxUPCIpdibELDGDPKRevaKy9j_Ob3UbTpAc54JjLr9ozk0eZkQOOtqZIvjhs9dpJFegR7671BpWb86vDh9kggG3CCOMAlh02gCCgyyPb_XYgx_LyLIs3AWua30TTQI5DtXlL0ArYNVkGmk__2RWqhTD_o5VEAGO621nTWJ6118GSTIg04gkcVPczVJ633i3hoY9_0E-X5v8tu59nE25ee_vVcq3K8lmTPNDFScqGOayj6f2nfPCvZu80yclH8VdqaC17KsLXNu3FGizmAUM4_2ORXDg-9wtTMIkxcr7_LhMtGiqYj3A1PR_KRRfGVWtvcvOpOaFlID3L94nZoq1qOXnVDj6IKF8E6p6dcgkWp_HDcF2CDipyK-noJ28Ixewsx-JwPQ8XaqRr2TcCyPbK4ZMic05_gJjB-_xNjCF7fheaFmW_FO_4r8b3RIvOaqcUTeQkyNcC-8efLK5yWLNs-g-rpIsNMIYzemeglFbW_KoH0B43_jUZtAW0fbqKXuJSl5VI8fGSQFXDNlcXJi1bGmRJ8AOiWyUFQwy5BY8GbZUIYvjCDZIy7nroPde6BYluvNcXi5M35vm78fM7d_gott8rWLFfQGv3oWvTjbPInKvyaunWUdq9Bh2CAWdiQ
>> curl -X GET "https://a926512406d7411eaa663064b99b1f5c-1701160476.us-east-2.elb.amazonaws.com:9095/petstorejwt/v1/pet/5" -H "accept: application/xml" -H "Authorization:Bearer $TOKEN" -k
```

- You can access the Microgateway/Synapse Gateway using the external ips provided by the LB.

Output:
```sh
<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Pet><id>5</id><name>xBpOBvzhTO</name><photoUrls><photoUrl>https://i.ytimg.com/vi/SfLV8hD7zX4/maxresdefault.jpg</photoUrl><photoUrl>url2</photoUrl></photoUrls><status>sold</status><tags/></Pet>
```
## Clean up

If you need to remove only the deployment from the AWS EKS cluster execute the following command.
```sh
>> kubectl delete -f configured/
```
Or else,

- Delete the AWS ECR repository.
- Delete the AWS EKS cluster.
- Delete the AWS EFS storage.
