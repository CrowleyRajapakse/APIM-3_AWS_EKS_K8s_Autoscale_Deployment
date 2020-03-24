import ballerina/http;
import ballerina/log;
import ballerina/kubernetes;
 
@kubernetes:Service {
   name: "vehicleInfo",
   serviceType: "LoadBalancer"
}

@kubernetes:Deployment {
   name: "vehicleInfo"
}

service entities on new http:Listener(8080) {
   @http:ResourceConfig {
        methods: ["GET"],
        path: "/vehicles/{v_id}"
    }
    resource function getid(http:Caller caller, http:Request req,
                                string v_id) {
        json[] vehicles = [
        { id: "25", reg_driver: "Allen Wallace", model: "Defender", year: 2015, city: "New York"  },
        { id: "26", reg_driver: "Ying Yue", model: "Evoque", year: 2016, city: "Miami"  },
        { id: "27", reg_driver: "Lew Green", model: "Discovery", year: 2013, city: "Chicago"  }
        ];

        json responseJson = {  "error": "vehicle with the provided id not found!" };

        foreach var vehicle in vehicles {
            json|error id = vehicle.id;
            if (id == v_id) {
                responseJson = vehicle;
            }
        }
        http:Response res = new;

        res.setJsonPayload(<@untainted> responseJson);

        var result = caller->respond(res);

        if (result is error) {
            log:printError("Error when responding", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/vehicles"
    }
    resource function getall(http:Caller caller, http:Request req) {
    	json[] vehicles = [
        { id: "25", reg_driver: "Allen Wallace", model: "Defender", year: 2015, city: "New York"  },
        { id: "26", reg_driver: "Ying Yue", model: "Evoque", year: 2016, city: "Miami"  },
        { id: "27", reg_driver: "Lew Green", model: "Discovery", year: 2013, city: "Chicago"  }
        ];

        json responseJson = vehicles;

        http:Response res = new;

        res.setJsonPayload(<@untainted> responseJson);

        var result = caller->respond(res);

        if (result is error) {
            log:printError("Error when responding", err = result);
        }
    }
}