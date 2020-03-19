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

```sh
>> curl -X GET "https://ad998945664e011eabf900aa2059d57f-933146450.us-east-2.elb.amazonaws.com:32001/carbon/admin/login.jsp" -k -v
```


- You can access the Microgateway using the external ip provided by the LB.

You can use the following sample token.
```sh
>> TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlpqUm1ZVE13TlRKak9XVTVNbUl6TWpnek5ESTNZMkl5TW1JeVkyRXpNamRoWmpWaU1qYzBaZz09In0.eyJhdWQiOiJodHRwOlwvXC9vcmcud3NvMi5hcGltZ3RcL2dhdGV3YXkiLCJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhcHBsaWNhdGlvbiI6eyJvd25lciI6ImFkbWluIiwidGllciI6IlVubGltaXRlZCIsIm5hbWUiOiJzYW1wbGUtY3JkLWFwcGxpY2F0aW9uIiwiaWQiOjMsInV1aWQiOm51bGx9LCJzY29wZSI6ImFtX2FwcGxpY2F0aW9uX3Njb3BlIGRlZmF1bHQiLCJpc3MiOiJodHRwczpcL1wvd3NvMmFwaW06MzIwMDFcL29hdXRoMlwvdG9rZW4iLCJ0aWVySW5mbyI6e30sImtleXR5cGUiOiJQUk9EVUNUSU9OIiwic3Vic2NyaWJlZEFQSXMiOltdLCJjb25zdW1lcktleSI6IjNGSWlUM1R3MWZvTGFqUTVsZjVVdHVTTWpsUWEiLCJleHAiOjM3MTk3Mzk4MjYsImlhdCI6MTU3MjI1NjE3OSwianRpIjoiZDI3N2VhZmUtNTZlOS00MTU2LTk3NzUtNDQwNzA3YzFlZWFhIn0.W0N9wmCuW3dxz5nTHAhKQ-CyjysR-fZSEvoS26N9XQ9IOIlacB4R5x9NgXNLLE-EjzR5Si8ou83mbt0NuTwoOdOQVkGqrkdenO11qscpBGCZ-Br4Gnawsn3Yw4a7FHNrfzYnS7BZ_zWHPCLO_JqPNRizkWGIkCxvAg8foP7L1T4AGQofGLodBMtA9-ckuRHjx3T_sFOVGAHXcMVwpdqS_90DeAoT4jLQ3darDqSoE773mAyDIRz6CAvNzzsWQug-i5lH5xVty2kmZKPobSIziAYes-LPuR-sp61EIjwiKxnUlSsxtDCttKYHGZcvKF12y7VF4AqlTYmtwYSGLkXXXw
```
Then execute the following CURL command to invoke the API.
```sh
>> curl -X GET "https://a0f49e200650e11eaa663064b99b1f5c-734753146.us-east-2.elb.amazonaws.com:9095/petstore/v1/pet/5" -H "accept: application/xml" -H "Authorization:Bearer $TOKEN" -k
```

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
