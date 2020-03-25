# Pod Resilancy Test 

Here, we are going to terminate a running pod(Ex: microgateway deployment) and see whether a new pod is getting started instead of the terminated pod.

### MicroGateway Resilancy Testing

1 . Verifying what are the pods running normally.
 
 ```sh
 >> kubectl get pods
 ```

Output:

```sh
NAME                              READY   STATUS    RESTARTS   AGE
petstore-jwt-57d8c4ff7-wp4bv      1/1     Running   0          26h
vehicle-info-mg-cf9f97b95-dltxv   1/1     Running   0          16h
vehicleinfo-996b7cf5-78x96        1/1     Running   0          21h
```

note: 
- vehicle-info-mg-cf9f97b95-dltxv is the VehicleInfo API deployed as a Microgateway(which will be used in the demo)
- vehicleinfo-996b7cf5-78x96 is the backend of the VehicleInfo API.
- petstore-jwt-57d8c4ff7-wp4bv is the default api deployed as a Microgateway to verify the scenario.

2 . Terminate the relevant pod  

 ```sh
 >> kubectl delete pods vehicle-info-mg-cf9f97b95-dltxv
 ```

Output:

```sh
pod "vehicle-info-mg-cf9f97b95-dltxv" deleted
```

3 . Finally verify the new created pod.

```sh
 >> kubectl get pods
```

Output:

```sh
AME                              READY   STATUS    RESTARTS   AGE
petstore-jwt-57d8c4ff7-wp4bv      1/1     Running   0          26h
vehicle-info-mg-cf9f97b95-6cnnc   1/1     Running   0          43s
vehicleinfo-996b7cf5-78x96        1/1     Running   0          22h
```

Note: A New vehicle-info-mg-cf9f97b95-6cnnc pod is up and running.


### Gateway Resilancy Testing

Need to follow the same above steps with correct namespace(-n wso2).
