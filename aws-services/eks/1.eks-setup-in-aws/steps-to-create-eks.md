Source = https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/

step1- install kubectl by downloading .exe file from below link, later set environment and verify using command this [kubectl version --client]
		https://github.com/weaveworks/eksctl/releases/download/v0.86.0/eksctl_Windows_amd64.zip

step2- install eksctl by downloading .exe file from below link, later set environment and verify using command this [eksctl version]
		https://www.edureka.co/community/74468/how-to-install-eksctl-command-in-windows

step3- install helm by downloading zip file from below link, later set environment and verify using command this [helm version]
		https://get.helm.sh/helm-v3.8.0-windows-amd64.zip
		source = https://github.com/helm/helm/releases


# open powershell

cd D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work
eksctl create cluster --name new --version 1.21 --fargate
eksctl utils associate-iam-oidc-provider --cluster new --approve
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

eksctl create iamserviceaccount --cluster=new --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::674159014239:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --approve

eksctl get iamserviceaccount --cluster new --name aws-load-balancer-controller --namespace kube-system

# Install the AWS Load Balancer Controller using Helm
helm repo add eks https://aws.github.io/eks-charts

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=new --set serviceAccount.create=false --set region=us-west-1 --set vpcId=vpc-0883ffaf700756615 --set serviceAccount.name=aws-load-balancer-controller -n kube-system

eksctl create fargateprofile --cluster new --region us-west-1 --name new-fargate --namespace game-2048

curl -o 2048_full.yaml  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/examples/2048/2048_full.yaml

kubectl apply -f 2048_full.yaml

kubectl get ingress/ingress-2048 -n game-2048

kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller


PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> kubectl get ingress
No resources found in default namespace.
PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> kubectl config set-context --current --namespace=game-2048
Context "iam-root-account@new.us-west-1.eksctl.io" modified.
PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> kubectl get ingress
NAME           CLASS    HOSTS   ADDRESS                                                                  PORTS   AGE
ingress-2048   <none>   *       k8s-game2048-ingress2-3d1b4daa7a-597574991.us-west-1.elb.amazonaws.com   80      65s
PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> ^C
PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
deployment-2048-79785cfdff-tnj85   1/1     Running   0          104s
PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> kubectl get ingress
NAME           CLASS    HOSTS   ADDRESS                                                                  PORTS   AGE
ingress-2048   <none>   *       k8s-game2048-ingress2-3d1b4daa7a-597574991.us-west-1.elb.amazonaws.com   80      3m54s
PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work>

Note:
Go to loadbalancer security-group, then add "all traffic". Later we can access webpage with dns of load-balancer
========================================================================================================================================
