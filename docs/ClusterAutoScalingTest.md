# Cluster AutoScaling Test 

Here, we are going to create more replicas of a running pod(Ex: microgateway deployment) and see whether a new node is getting started instead to cater the resource requirements.

### Cluster AutoScaling Testing

1 . Verifying what are the pods running normally.
 
 ```sh
 >> kubectl get pods
 ```

Output:

```sh
NAME                                 READY   STATUS    RESTARTS   AGE
petstore-jwt-57d8c4ff7-wp4bv         1/1     Running   0          2d7h
vehicle-info-auto-65d69679bd-t7zsl   1/1     Running   0          22h
vehicle-info-mg-cf9f97b95-6cnnc      1/1     Running   0          28h
vehicleinfo-996b7cf5-78x96           1/1     Running   0          2d2h
```

note: 
- petstore-jwt-57d8c4ff7-wp4bv is the default api deployed as a Microgateway to verify the scenario(This will be used in this demo).
- vehicle-info-mg-cf9f97b95-dltxv is the VehicleInfo API deployed as a Microgateway
- vehicle-info-auto-65d69679bd-t7zsl is the VehicleInfo-Auto API deployed as a Microgateway
- vehicleinfo-996b7cf5-78x96 is the backend of the VehicleInfo API.

2 . Verifying what are the nodes running normally.
 
 ```sh
 >> kubectl get nodes
 ```

Output:

```sh
NAME                                          STATUS   ROLES    AGE   VERSION
ip-172-31-24-135.us-east-2.compute.internal   Ready    <none>   13d   v1.14.8-eks-b8860f
ip-172-31-3-184.us-east-2.compute.internal    Ready    <none>   13d   v1.14.8-eks-b8860f
```

note: 
- ip-172-31-24-135.us-east-2.compute.internal is a node activated in the creation of the cluster.
- ip-172-31-3-184.us-east-2.compute.internal is a node activated in the creation of the cluster.

3 . Edit the relevant HPA policy to replicate more pods  

- Step 1 (View)
 ```sh
 >> kubectl get hpa
 ```

Output:

```sh
NAME                    REFERENCE                      TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
petstore-jwt-hpa        Deployment/petstore-jwt        1%/50%    1         5         1          2d7h
vehicle-info-auto-hpa   Deployment/vehicle-info-auto   1%/50%    1         5         1          22h
vehicle-info-mg-hpa     Deployment/vehicle-info-mg     1%/50%    1         5         1          46h
```

- Step 2 (Edit)
 ```sh
 >> kubectl edit hpa petstore-jwt-hpa
 ```

Output:

```sh
horizontalpodautoscaler.autoscaling/petstore-jwt-hpa edited
```

- Step 3 (Verify)
 ```sh
 >> kubectl get hpa
 ```

Output:

```sh
NAME                    REFERENCE                      TARGETS   MINPODS    MAXPODS    REPLICAS   AGE
petstore-jwt-hpa        Deployment/petstore-jwt        1%/50%    19         20         1          2d7h
vehicle-info-auto-hpa   Deployment/vehicle-info-auto   1%/50%     1          5         1          22h
vehicle-info-mg-hpa     Deployment/vehicle-info-mg     1%/50%     1          5         1          46h
```

4 . Verify the new replicas of Microgateway pods are getting initialized.

```sh
 >> kubectl get pods
```

Output:

```sh
NAME                                 READY   STATUS    RESTARTS   AGE
petstore-jwt-57d8c4ff7-2xpvf         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-55smd         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-cfbm4         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-cwl5r         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-d4bd7         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-f7rzm         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-gldjc         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-h4j8h         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-kbfkg         0/1     Running   0          4s
petstore-jwt-57d8c4ff7-lqbkt         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-q7h8p         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-qc82h         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-qs6mx         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-sbrg9         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-sw86r         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-wflzv         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-wp4bv         1/1     Running   0          2d7h
petstore-jwt-57d8c4ff7-xv7nv         0/1     Pending   0          4s
petstore-jwt-57d8c4ff7-zlv75         0/1     Pending   0          4s
vehicle-info-auto-65d69679bd-t7zsl   1/1     Running   0          22h
vehicle-info-mg-cf9f97b95-6cnnc      1/1     Running   0          28h
vehicleinfo-996b7cf5-78x96           1/1     Running   0          2d2h
```

Note: A number new pods of petstore-jwt are getting replicated, hence exceeding the cpu and memory limits fhe current two nodes.

5 . Start Monitoring logs of Cluster AutoScaler to get an idea of whats happening.

```sh
 >> kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler
```

Output:

```sh
I0326 09:28:48.692475       1 static_autoscaler.go:147] Starting main loop
I0326 09:28:48.694374       1 utils.go:626] No pod using affinity / antiaffinity found in cluster, disabling affinity predicate for this loop
I0326 09:28:48.694524       1 static_autoscaler.go:303] Filtering out schedulables
I0326 09:28:48.694724       1 static_autoscaler.go:320] No schedulable pods
I0326 09:28:48.694797       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-sbrg9 is unschedulable
I0326 09:28:48.694861       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-lqbkt is unschedulable
I0326 09:28:48.695197       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-2xpvf is unschedulable
I0326 09:28:48.695270       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-cfbm4 is unschedulable
I0326 09:28:48.695291       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-f7rzm is unschedulable
I0326 09:28:48.695412       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-sw86r is unschedulable
I0326 09:28:48.695650       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-gldjc is unschedulable
I0326 09:28:48.695680       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-wflzv is unschedulable
I0326 09:28:48.695713       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-cwl5r is unschedulable
I0326 09:28:48.695744       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-h4j8h is unschedulable
I0326 09:28:48.695750       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-q7h8p is unschedulable
I0326 09:28:48.695755       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-qs6mx is unschedulable
I0326 09:28:48.695760       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-xv7nv is unschedulable
I0326 09:28:48.695765       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-zlv75 is unschedulable
I0326 09:28:48.695772       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-qc82h is unschedulable
I0326 09:28:48.695776       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-55smd is unschedulable
I0326 09:28:48.695781       1 scale_up.go:263] Pod default/petstore-jwt-57d8c4ff7-d4bd7 is unschedulable
I0326 09:28:48.695832       1 scale_up.go:300] Upcoming 0 nodes
I0326 09:28:48.700572       1 waste.go:57] Expanding Node Group eks-18b868fe-c4ef-0de7-33de-faf02876096e would waste 29.17% CPU, 62.66% Memory, 45.91% Blended
I0326 09:28:48.700696       1 scale_up.go:423] Best option to resize: eks-18b868fe-c4ef-0de7-33de-faf02876096e
I0326 09:28:48.700766       1 scale_up.go:427] Estimated 6 nodes needed in eks-18b868fe-c4ef-0de7-33de-faf02876096e
I0326 09:28:48.700826       1 balancing_processor.go:109] Requested scale-up (6) exceeds node group set capacity, capping to 1
I0326 09:28:48.700874       1 scale_up.go:529] Final scale-up plan: [{eks-18b868fe-c4ef-0de7-33de-faf02876096e 2->3 (max: 3)}]
I0326 09:28:48.700930       1 scale_up.go:694] Scale-up: setting group eks-18b868fe-c4ef-0de7-33de-faf02876096e size to 3
I0326 09:28:48.701009       1 auto_scaling_groups.go:221] Setting asg eks-18b868fe-c4ef-0de7-33de-faf02876096e size to 3
I0326 09:28:48.701082       1 event.go:209] Event(v1.ObjectReference{Kind:"ConfigMap", Namespace:"kube-system", Name:"cluster-autoscaler-status", UID:"22babb52-6f41-11ea-a663-064b99b1f5ca", APIVersion:"v1", ResourceVersion:"1977735", FieldPath:""}): type: 'Normal' reason: 'ScaledUpGroup' Scale-up: setting group eks-18b868fe-c4ef-0de7-33de-faf02876096e size to 3
I0326 09:28:48.865236       1 event.go:209] Event(v1.ObjectReference{Kind:"Pod", Namespace:"default", Name:"petstore-jwt-57d8c4ff7-q7h8p", UID:"2f7db18a-6f44-11ea-bf90-0aa2059d57fc", APIVersion:"v1", ResourceVersion:"1977821", FieldPath:""}): type: 'Normal' reason: 'TriggeredScaleUp' pod triggered scale-up: [{eks-18b868fe-c4ef-0de7-33de-faf02876096e 2->3 (max: 3)}]
```

Notes: 
- Only have specified 3 maximum nodes and 2 minimum nodes in the cluster configurations.
- In order to cater the resource requirements they need maximum 6 nodes, but since we only have specified maximum 3, the cluster autoscaler will at least scaled the nodes up to 3.

6 . Check the new node getting spinning up.

```sh
 >> kubectl get nodes
 ```

Output:

```sh
NAME                                          STATUS   ROLES    AGE   VERSION
ip-172-31-24-135.us-east-2.compute.internal   Ready    <none>   13d   v1.14.8-eks-b8860f
ip-172-31-3-184.us-east-2.compute.internal    Ready    <none>   13d   v1.14.8-eks-b8860f
ip-172-31-37-121.us-east-2.compute.internal   Ready    <none>   17s   v1.14.8-eks-b8860f
```

note: 
- ip-172-31-37-121.us-east-2.compute.internal is the new node which getting created to cater the resource requirements.
- ip-172-31-24-135.us-east-2.compute.internal is a node activated in the initial creation of the cluster.
- ip-172-31-3-184.us-east-2.compute.internal is a node activated in the initial creation of the cluster.


7 . Re-edit the HPA policy to reduce the number of replicas. (same as step 3)

8 . In the Cluster AutoScaler logs following can be seen after a 15 minutes of slack time.

```sh
I0326 09:46:23.492418       1 static_autoscaler.go:412] Starting scale down
I0326 09:46:23.492452       1 scale_down.go:647] ip-172-31-37-121.us-east-2.compute.internal was unneeded for 9m52.828068173s
I0326 09:46:23.492466       1 scale_down.go:706] No candidates for scale down
I0326 09:46:27.048329       1 reflector.go:370] k8s.io/autoscaler/cluster-autoscaler/utils/kubernetes/listers.go:339: Watch close - *v1.Job total 0 items received
I0326 09:46:33.500116       1 static_autoscaler.go:147] Starting main loop
I0326 09:46:33.500788       1 utils.go:471] Removing autoscaler soft taint when creating template from node ip-172-31-37-121.us-east-2.compute.internal
I0326 09:46:33.501086       1 utils.go:626] No pod using affinity / antiaffinity found in cluster, disabling affinity predicate for this loop
I0326 09:46:33.501148       1 static_autoscaler.go:303] Filtering out schedulables
I0326 09:46:33.501247       1 static_autoscaler.go:320] No schedulable pods
I0326 09:46:33.501298       1 static_autoscaler.go:328] No unschedulable pods
I0326 09:46:33.501341       1 static_autoscaler.go:375] Calculating unneeded nodes
I0326 09:46:33.501543       1 scale_down.go:410] Node ip-172-31-3-184.us-east-2.compute.internal - utilization 0.898367
I0326 09:46:33.501636       1 scale_down.go:414] Node ip-172-31-3-184.us-east-2.compute.internal is not suitable for removal - utilization too big (0.898367)
I0326 09:46:33.501694       1 scale_down.go:410] Node ip-172-31-24-135.us-east-2.compute.internal - utilization 0.632124
I0326 09:46:33.501759       1 scale_down.go:414] Node ip-172-31-24-135.us-east-2.compute.internal is not suitable for removal - utilization too big (0.632124)
I0326 09:46:33.501826       1 scale_down.go:410] Node ip-172-31-37-121.us-east-2.compute.internal - utilization 0.056995
I0326 09:46:33.501983       1 static_autoscaler.go:391] ip-172-31-37-121.us-east-2.compute.internal is unneeded since 2020-03-26 09:36:30.663647562 +0000 UTC m=+755.341842780 duration 10m2.836440719s
I0326 09:46:33.502229       1 static_autoscaler.go:402] Scale down status: unneededOnly=false lastScaleUpTime=2020-03-26 09:28:48.692447744 +0000 UTC m=+293.370643009 lastScaleDownDeleteTime=2020-03-26 09:23:57.782866798 +0000 UTC m=+2.461062002 lastScaleDownFailTime=2020-03-26 09:23:57.782866868 +0000 UTC m=+2.461062070 scaleDownForbidden=false isDeleteInProgress=false
I0326 09:46:33.502320       1 static_autoscaler.go:412] Starting scale down
I0326 09:46:33.502403       1 scale_down.go:647] ip-172-31-37-121.us-east-2.compute.internal was unneeded for 10m2.836440719s
I0326 09:46:33.502547       1 scale_down.go:866] Scale-down: removing empty node ip-172-31-37-121.us-east-2.compute.internal
I0326 09:46:33.504840       1 event.go:209] Event(v1.ObjectReference{Kind:"ConfigMap", Namespace:"kube-system", Name:"cluster-autoscaler-status", UID:"22babb52-6f41-11ea-a663-064b99b1f5ca", APIVersion:"v1", ResourceVersion:"1980891", FieldPath:""}): type: 'Normal' reason: 'ScaleDownEmpty' Scale-down: removing empty node ip-172-31-37-121.us-east-2.compute.internal
I0326 09:46:33.513605       1 delete.go:102] Successfully added ToBeDeletedTaint on node ip-172-31-37-121.us-east-2.compute.internal
I0326 09:46:33.719841       1 auto_scaling_groups.go:279] Terminating EC2 instance: i-0c417a69aee25fd41
I0326 09:46:33.719860       1 aws_manager.go:291] Some ASG instances might have been deleted, forcing ASG list refresh
I0326 09:46:33.768257       1 auto_scaling_groups.go:354] Regenerating instance to ASG map for ASGs: [eks-18b868fe-c4ef-0de7-33de-faf02876096e]
I0326 09:46:33.856532       1 aws_manager.go:263] Refreshed ASG list, next refresh after 2020-03-26 09:47:33.856526328 +0000 UTC m=+1418.534721559
I0326 09:46:33.857042       1 event.go:209] Event(v1.ObjectReference{Kind:"ConfigMap", Namespace:"kube-system", Name:"cluster-autoscaler-status", UID:"22babb52-6f41-11ea-a663-064b99b1f5ca", APIVersion:"v1", ResourceVersion:"1980891", FieldPath:""}): type: 'Normal' reason: 'ScaleDownEmpty' Scale-down: empty node ip-172-31-37-121.us-east-2.compute.internal removed
ip-172-31-37-121.us-east-2.compute.internal
```

6 . Check the nodes available after scaling down

```sh
 >> kubectl get nodes
 ```

Output:

```sh
NAME                                          STATUS   ROLES    AGE   VERSION
ip-172-31-24-135.us-east-2.compute.internal   Ready    <none>   13d   v1.14.8-eks-b8860f
ip-172-31-3-184.us-east-2.compute.internal    Ready    <none>   13d   v1.14.8-eks-b8860f
```

Note: 
- Here, only the minimum number nodes are in active state.
- ip-172-31-37-121.us-east-2.compute.internal node has been deleted automatically by the Cluster AutoScaler to remove the unneeded resources.

