**Debugging Section**  
  
**1\. CrashLoopBackOff – Wrong Command**  
command: \["python", "main.py"\] → file is app.py.

Command was set to "python main.py" but file name is app.py

To fix this  

We have to Update Kubernetes deployment to:

command: \["python", "app.py"\]

Then when we run

kubectl get pods  
The status will change to running

  
**2\. Ingress Route Failure**  
Ingress routes /backend but backend listens on /api.

The error which we will get might be Accessing /api/health will return **404 Not Found page**

The error is Backend endpoint was /health but ingress routed /api/health**

 To fix this  
 We have to Update Flask app route to:

@app.route("/api/health")**

  
**3\. Terraform Backend Error**  
Missing bucket/container name.  
For the missing bucket or container name the issue might be permission to read azure storage keys  

To fix this  
We have to Grant Contributor role on Storage Account and updated backend config in providers.tf then we have to varify it by commands using tf init

  
**4\. FluentBit Log Path Bug**  
Incorrect path: \*.logx instead of \*.log.

We have to correct the path, here “x” is extra so I think we have to remove this  
The corrected paath will be  
/var/log/containers/\*.log  
Then kibana will store log paths