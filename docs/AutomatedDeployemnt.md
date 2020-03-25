# Automated Deployment of APIs to Standard Gateway and Microgateway in AWS K8s Cluster

Here, we are going to import and deploy an API from a swagger definition to both Standard Gateway and MicroGateway.

## Using API Operator Dev 1st Approach

### Setup API Operator
Need to follow following documentation to setup API Operator. 
[Setting up API Operator](https://apim.docs.wso2.com/en/latest/learn/api-controller/getting-started-with-wso2-api-controller/)

### Deploy an API to Standard Gateway in AWS K8s Cluster in US region

1 . Add the environment.(EU All In One Node)

```sh
 >> apictl add-env -e aio --registration https://35.228.218.176:9443/client-registration/v0.15/register --apim https://35.228.218.176:9443 --token https://35.228.218.176:8243/token --admin https://35.228.218.176:9443/api/am/admin/v0.15 --api_list https://35.228.218.176:9443/api/am/publisher/v0.15/apis --app_list https://35.228.218.176:9443/api/am/store/v0.15/applications
```

Output:

```sh
Successfully added environment 'aio'
```

2 . Initialize the API Project using the swagger provided in the <REPO_HOME>/automated-deployment-artifacts/standard-gateway/swagger.yaml .

 ```sh
 >> apictl init vehicle-info-auto --oas=swagger.yaml --initial-state=PUBLISHED
 ```

Output:

```sh
Initializing a new WSO2 API Manager project in /Users/sampath/POC/AWS_k8s_deployment_Scripts/dev1st/gateway/vehicle-info-auto
Project initialized
Open README file to learn more
```

3 . Import the created API to 'aio' environment.

 ```sh
 >> apictl import-api -f vehicle-info-auto/ -e aio -k
 ```

Output:

```sh
Successfully imported API
```

4 . Can verify the deploying of API by logging into the Publisher or Devprotal of the AIO setup.

Link: https://35.228.218.176:9443/publisher/apis

![Published API](../images/published-api.png)


3 . Generate an Access Token to invoke the API.

Generate a token from Central-EU-All-in-One node for VehicleInfo-US-Auto API (https://35.228.218.176:9443/devportal/apis/)

![Generate Access Token](../images/generate-access-token.png)

```sh
 >> curl -X GET "https://ad998945664e011eabf900aa2059d57f-933146450.us-east-2.elb.amazonaws.com:30801/vehicle-info-auto/us/1/entities/vehicles/25" -H  "accept: */*" -H  "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik9UZ3pPRE0wTlRVMU1EQTVPVFppWTJFM1ptUmlOVFpsWkRVek9UUTNZMk0yWW1VeFlqVmtOQT09In0.eyJhdWQiOiJodHRwOlwvXC9vcmcud3NvMi5hcGltZ3RcL2dhdGV3YXkiLCJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhcHBsaWNhdGlvbiI6eyJvd25lciI6ImFkbWluIiwidGllciI6IlVubGltaXRlZCIsIm5hbWUiOiJUZXN0SldUIiwiaWQiOjUsInV1aWQiOm51bGx9LCJzY29wZSI6ImFtX2FwcGxpY2F0aW9uX3Njb3BlIGRlZmF1bHQiLCJpc3MiOiJodHRwczpcL1wvMzUuMjI4LjIxOC4xNzY6OTQ0M1wvb2F1dGgyXC90b2tlbiIsInRpZXJJbmZvIjp7IlVubGltaXRlZCI6eyJzdG9wT25RdW90YVJlYWNoIjp0cnVlLCJzcGlrZUFycmVzdExpbWl0IjowLCJzcGlrZUFycmVzdFVuaXQiOm51bGx9fSwia2V5dHlwZSI6IlBST0RVQ1RJT04iLCJzdWJzY3JpYmVkQVBJcyI6W3sic3Vic2NyaWJlclRlbmFudERvbWFpbiI6ImNhcmJvbi5zdXBlciIsIm5hbWUiOiJQZXRzdG9yZS1BUEkiLCJjb250ZXh0IjoiXC9wZXRzdG9yZVwvdjFcL3YxIiwicHVibGlzaGVyIjoiYWRtaW4iLCJ2ZXJzaW9uIjoidjEiLCJzdWJzY3JpcHRpb25UaWVyIjoiVW5saW1pdGVkIn0seyJzdWJzY3JpYmVyVGVuYW50RG9tYWluIjoiY2FyYm9uLnN1cGVyIiwibmFtZSI6IlBldHN0b3JlLUp3dCIsImNvbnRleHQiOiJcL3BldHN0b3Jland0XC92MSIsInB1Ymxpc2hlciI6ImFkbWluIiwidmVyc2lvbiI6InYxIiwic3Vic2NyaXB0aW9uVGllciI6IlVubGltaXRlZCJ9LHsic3Vic2NyaWJlclRlbmFudERvbWFpbiI6ImNhcmJvbi5zdXBlciIsIm5hbWUiOiJWZWhpY2xlSW5mby1VUyIsImNvbnRleHQiOiJcL3ZlaGljbGUtaW5mb1wvdXNcLzEiLCJwdWJsaXNoZXIiOiJhZG1pbiIsInZlcnNpb24iOiIxIiwic3Vic2NyaXB0aW9uVGllciI6IlVubGltaXRlZCJ9LHsic3Vic2NyaWJlclRlbmFudERvbWFpbiI6ImNhcmJvbi5zdXBlciIsIm5hbWUiOiJWZWhpY2xlSW5mby1VUy1BdXRvIiwiY29udGV4dCI6IlwvdmVoaWNsZS1pbmZvLWF1dG9cL3VzXC8xIiwicHVibGlzaGVyIjoiYWRtaW4iLCJ2ZXJzaW9uIjoiMSIsInN1YnNjcmlwdGlvblRpZXIiOiJVbmxpbWl0ZWQifV0sImNvbnN1bWVyS2V5IjoiSDZXYm5BZUFINlhNZ0d1ZkhTS3oyNF9NeldrYSIsImV4cCI6MTU4NTEzNjAwMSwiaWF0IjoxNTg1MTMyNDAxLCJqdGkiOiIxYjRjNTI5NC00MDJlLTQ5MTUtOTAzZC1kOTI4NDM1YTEyMmYifQ.iyJL1pqHt2TuYodDYOTsbfbsOx-rHv97uheVr6wV5DWN6qmCT6xqZCjS0cSnxG_2G2us__4nwLFb7d9XEZGfaTJIkEureUmQPqZTe6EV2vyReay99l8TlD1b-jKMH1zuMqZJHJ90a-UZz7ifY-HTreiEfM5AX-xvC5tcCBeVIohLAldpQbDZvOXPjCqX223GV2hJnJjwZDt2bGr2ywVrLfykaw4nEvtP0qFVnI5X8Z8vJMn7EtyJIJu93xcb05Vf_uM_FrRJ6uVqpLxtoq-1z9T1t7zt9BKAZnZH2ann65OuZYbZQukm5HhK8_vKMKHHMgNJmK18W5Qlf-IFwz8OtNVkqMk_eaI-KNIP00Jw9h60A2BVs2d7Qztbc5IQutQNLyjYLv4N71xCKNIumKqAe56Xmt1LgbizfYb4Wfx2An8Rzy-h7Sg_ZY0u-rsW5YDJKPPA2sz42AO2i7Be-a-5eLbnmmn04uodDTxTGvumEdaUyaLGD7Jo-pEUS3MsuaMYS-t_S8VgY0wAF5OZx_rw8aR4E-yqvJp6jCMQa8kt7e61N-M6UYF0WaG1qFALNSgkwutu0damVQSGjp6K0IcVbr8SjWAi9Ukh0KTSeicTHDvvZWgGAr79WhUMEj5tB0BNs5X6GBdQRq5FALYK_0rUGNQnXgLNKS7L8fbRpishmKc" -k
```

Output:

```sh
{"id":"25", "reg_driver":"Allen Wallace", "model":"Defender", "year":2015, "city":"New York"}
```


### Deploy an API to MicroGateway in AWS K8s Cluster in US region.

1 . Deploy a Microgateway in k8s using a swagger definition.

You need to use the swagger provided in the <REPO_HOME>/automated-deployment-artifacts/microgateway/swagger.yaml .

 ```sh
 >> apictl add api -n vehicle-info-auto --from-file=swagger.yaml
 ```

Output:

```sh
creating configmap with swagger definition
configmap/vehicle-info-auto-swagger created
api.wso2.com/vehicle-info-auto created
```

2 . Verifying whether the vehicle-info-auto Microgateway deployed successfully.
 
 ```sh
 >> kubectl get pods
 ```

Output:

```sh
NAME                                 READY   STATUS    RESTARTS   AGE
petstore-jwt-57d8c4ff7-wp4bv         1/1     Running   0          32h
vehicle-info-auto-65d69679bd-t7zsl   1/1     Running   0          2m32s
vehicle-info-mg-cf9f97b95-6cnnc      1/1     Running   0          6h5m
vehicleinfo-996b7cf5-78x96           1/1     Running   0          28h
```

note: 
- vehicle-info-auto-65d69679bd-t7zsl is the newly deployed Microgateway.
- vehicle-info-mg-cf9f97b95-dltxv is the VehicleInfo API deployed as a Microgateway previously to be used in previous scenarios.
- vehicleinfo-996b7cf5-78x96 is the backend of the VehicleInfo API.
- petstore-jwt-57d8c4ff7-wp4bv is the default api deployed as a Microgateway to verify the scenario.

3 . Retrieve the external IP address of the microgateway deployment.

 ```sh
 >> kubectl get svc
 ```

Output:

```sh
NAME                TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                         AGE
kubernetes          ClusterIP      10.100.0.1       <none>                                                                    443/TCP                         12d
petstore-jwt        LoadBalancer   10.100.133.57    a926512406d7411eaa663064b99b1f5c-1701160476.us-east-2.elb.amazonaws.com   9095:30721/TCP,9090:31399/TCP   32h
vehicle-info-auto   LoadBalancer   10.100.39.94     aa394ac556e8511eaa663064b99b1f5c-1938990723.us-east-2.elb.amazonaws.com   9095:31039/TCP,9090:30122/TCP   8m45s
vehicle-info-mg     LoadBalancer   10.100.107.186   a8b5e32246dc111eaa663064b99b1f5c-1976786525.us-east-2.elb.amazonaws.com   9095:32561/TCP,9090:32318/TCP   23h
vehicleinfo         LoadBalancer   10.100.83.38     a9638b7556d9711eaa663064b99b1f5c-1286476463.us-east-2.elb.amazonaws.com   8080:31717/TCP                  28h
```

4. Invoke the vehicle-info-auto API using the token generated previously.

```sh
 >> curl -X GET "https://aa394ac556e8511eaa663064b99b1f5c-1938990723.us-east-2.elb.amazonaws.com:9095/vehicle-info-auto/us/1/entities/vehicles/25" -H "accept: application/json" -H "Authorization:Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik9UZ3pPRE0wTlRVMU1EQTVPVFppWTJFM1ptUmlOVFpsWkRVek9UUTNZMk0yWW1VeFlqVmtOQT09In0.eyJhdWQiOiJodHRwOlwvXC9vcmcud3NvMi5hcGltZ3RcL2dhdGV3YXkiLCJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhcHBsaWNhdGlvbiI6eyJvd25lciI6ImFkbWluIiwidGllciI6IlVubGltaXRlZCIsIm5hbWUiOiJUZXN0SldUIiwiaWQiOjUsInV1aWQiOm51bGx9LCJzY29wZSI6ImFtX2FwcGxpY2F0aW9uX3Njb3BlIGRlZmF1bHQiLCJpc3MiOiJodHRwczpcL1wvMzUuMjI4LjIxOC4xNzY6OTQ0M1wvb2F1dGgyXC90b2tlbiIsInRpZXJJbmZvIjp7IlVubGltaXRlZCI6eyJzdG9wT25RdW90YVJlYWNoIjp0cnVlLCJzcGlrZUFycmVzdExpbWl0IjowLCJzcGlrZUFycmVzdFVuaXQiOm51bGx9fSwia2V5dHlwZSI6IlBST0RVQ1RJT04iLCJzdWJzY3JpYmVkQVBJcyI6W3sic3Vic2NyaWJlclRlbmFudERvbWFpbiI6ImNhcmJvbi5zdXBlciIsIm5hbWUiOiJQZXRzdG9yZS1BUEkiLCJjb250ZXh0IjoiXC9wZXRzdG9yZVwvdjFcL3YxIiwicHVibGlzaGVyIjoiYWRtaW4iLCJ2ZXJzaW9uIjoidjEiLCJzdWJzY3JpcHRpb25UaWVyIjoiVW5saW1pdGVkIn0seyJzdWJzY3JpYmVyVGVuYW50RG9tYWluIjoiY2FyYm9uLnN1cGVyIiwibmFtZSI6IlBldHN0b3JlLUp3dCIsImNvbnRleHQiOiJcL3BldHN0b3Jland0XC92MSIsInB1Ymxpc2hlciI6ImFkbWluIiwidmVyc2lvbiI6InYxIiwic3Vic2NyaXB0aW9uVGllciI6IlVubGltaXRlZCJ9LHsic3Vic2NyaWJlclRlbmFudERvbWFpbiI6ImNhcmJvbi5zdXBlciIsIm5hbWUiOiJWZWhpY2xlSW5mby1VUyIsImNvbnRleHQiOiJcL3ZlaGljbGUtaW5mb1wvdXNcLzEiLCJwdWJsaXNoZXIiOiJhZG1pbiIsInZlcnNpb24iOiIxIiwic3Vic2NyaXB0aW9uVGllciI6IlVubGltaXRlZCJ9LHsic3Vic2NyaWJlclRlbmFudERvbWFpbiI6ImNhcmJvbi5zdXBlciIsIm5hbWUiOiJWZWhpY2xlSW5mby1VUy1BdXRvIiwiY29udGV4dCI6IlwvdmVoaWNsZS1pbmZvLWF1dG9cL3VzXC8xIiwicHVibGlzaGVyIjoiYWRtaW4iLCJ2ZXJzaW9uIjoiMSIsInN1YnNjcmlwdGlvblRpZXIiOiJVbmxpbWl0ZWQifV0sImNvbnN1bWVyS2V5IjoiSDZXYm5BZUFINlhNZ0d1ZkhTS3oyNF9NeldrYSIsImV4cCI6MTU4NTEzNjAwMSwiaWF0IjoxNTg1MTMyNDAxLCJqdGkiOiIxYjRjNTI5NC00MDJlLTQ5MTUtOTAzZC1kOTI4NDM1YTEyMmYifQ.iyJL1pqHt2TuYodDYOTsbfbsOx-rHv97uheVr6wV5DWN6qmCT6xqZCjS0cSnxG_2G2us__4nwLFb7d9XEZGfaTJIkEureUmQPqZTe6EV2vyReay99l8TlD1b-jKMH1zuMqZJHJ90a-UZz7ifY-HTreiEfM5AX-xvC5tcCBeVIohLAldpQbDZvOXPjCqX223GV2hJnJjwZDt2bGr2ywVrLfykaw4nEvtP0qFVnI5X8Z8vJMn7EtyJIJu93xcb05Vf_uM_FrRJ6uVqpLxtoq-1z9T1t7zt9BKAZnZH2ann65OuZYbZQukm5HhK8_vKMKHHMgNJmK18W5Qlf-IFwz8OtNVkqMk_eaI-KNIP00Jw9h60A2BVs2d7Qztbc5IQutQNLyjYLv4N71xCKNIumKqAe56Xmt1LgbizfYb4Wfx2An8Rzy-h7Sg_ZY0u-rsW5YDJKPPA2sz42AO2i7Be-a-5eLbnmmn04uodDTxTGvumEdaUyaLGD7Jo-pEUS3MsuaMYS-t_S8VgY0wAF5OZx_rw8aR4E-yqvJp6jCMQa8kt7e61N-M6UYF0WaG1qFALNSgkwutu0damVQSGjp6K0IcVbr8SjWAi9Ukh0KTSeicTHDvvZWgGAr79WhUMEj5tB0BNs5X6GBdQRq5FALYK_0rUGNQnXgLNKS7L8fbRpishmKc" -k
```

Output:

```sh
{"id":"25", "reg_driver":"Allen Wallace", "model":"Defender", "year":2015, "city":"New York"}
```