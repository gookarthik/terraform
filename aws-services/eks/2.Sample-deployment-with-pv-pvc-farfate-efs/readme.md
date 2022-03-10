PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> kubectl apply -f .\fargate.yaml
storageclass.storage.k8s.io/efs-sc created
persistentvolume/efs-pv created
persistentvolumeclaim/efs-claim created
PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> kubectl apply -f sample-deploy-with-pv.yaml
deployment.apps/wordpress-ngnix created
PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> kubectl get pv
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                 STORAGECLASS   REASON   AGE
efs-pv              5Gi        RWX            Retain           Bound       game-2048/efs-claim   efs-sc                  23s
PS D:\SoftwareInstallation\Xyram-Servers-Work\Arcadia-Infra-Project\eks\practice-work> kubectl get pvc
NAME                      STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
efs-claim                 Bound     efs-pv   5Gi        RWX            efs-sc         28s
