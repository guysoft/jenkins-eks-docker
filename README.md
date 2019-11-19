# jenkins-eks-docker
Jenkins with eks kubectl and support [AWS EKS](https://aws.amazon.com/eks/)

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
        mountPath: //var/jenkins_home/.kube
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
