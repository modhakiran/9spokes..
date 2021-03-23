Note:- Prerequisite: awscli, kubctl, terraform, helm, docker, htpasswd, wget, curl
Use RHEL or Ubntu for install EKS and remaining steps.

#cd hello
#dockebuild -t hello:latest .

Change base on your account, modify "main.tf" change AWS_access or Secret_key..
    $terraform init
    $terraform plan
    $terraform apply

Access EKS cluster.
    $aws configure
    $aws eks --region <region> update-kubeconfig --name <cluster-name>
    $kubctl create namespace staging
    $kubctl get node #Check list of nodes.
    $kubectl label nodes <node-name> type=prod # Apply label in all list of nodes.
    $kubectl apply -f pod.yml
    $helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    $helm install prometheus prometheus-community/prometheus -n kube-system
    $helm repo add grafana https://grafana.github.io/helm-charts
    $helm install grafana grafana/grafana admin.userKey="admin" admin.passwordKey="password" -n kube-system

For Authentication you have to Generate password using two options.
  1) run below command in your linux or ubuntu box.
        $htpasswd -c auth admin
  2) you can generate online htpasswd generater 
    https://hostingcanada.org/htpasswd-generator/

    create file name with "auth". and past it value.

With the help of auth file create secret...

    $kubectl create secret generic basic-auth --from-file=auth -n kube-system

Install prometheus rules crds.
    $kubectl apply -f pcrd.yml
    $kubectl apply -f alart_rule.yml
    $kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/aws/deploy.yaml
    $kubectl apply -f nginx.yml

For better path base routing map with domain name.