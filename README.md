# jenkins-eks-docker
Jenkins with eks kubectl and support [AWS EKS](https://aws.amazon.com/eks/)

[DockerHub](https://hub.docker.com/r/guysoft/jenkins-eks)

# Example usage in kubernetes

1. Edit the [``stable/jenkins`` values.yaml](https://github.com/helm/charts/blob/master/stable/jenkins/values.yaml) helm chart to mount your aws credentials and kubectl from an EFS share or EBS. ANd use this image:
eg for NFS:

```
master:
  image: "guysoft/jenkins-eks"
agent:
  volumes:
    - name: kubectl
      nfs:
        server: XXXXX.amazonaws.com
        path: /deployment_path/kobectl
        mountPath: /var/jenkins_home/.kube
    - name: aws-cred
      nfs:
        server: XXXXX.efs.us-east-1.amazonaws.com
        path: /deployment_path/aws
        mountPath: /var/jenkins_home/.aws/
```
2. Install the release by running:
```
helm install stable/jenkins -f values.yaml --name jenkins
```
3. now kubectl should work from your jenkins master executor within kubernetes

# Run stuff from pods

You can use the provided ``get_random_pod`` to run something from a random pod that has a name label ``app.kubernetes.io/name``.
In jenkins you can use a command:
```
$ kubectl exec $(get_random_pod nginx) hostname
nginx-7846666659-xt5g4
```

