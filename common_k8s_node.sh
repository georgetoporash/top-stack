apt update

cd /tmp;ssh-keygen -b 2048 -t rsa -f k8s_deploy -N ""; \
useradd -m -d /var/lib/k8s_deploy k8s_deploy; \
echo "k8s_deploy ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/k8s_deploy; \
mkdir -p /var/lib/k8s_deploy/.ssh; \
echo $(cat k8s_deploy.pub) >> /var/lib/k8s_deploy/.ssh/authorized_keys; \
chown k8s_deploy:k8s_deploy -R /var/lib/k8s_deploy; \
chmod 700 /var/lib/k8s_deploy/.ssh/; \
chmod 600 /var/lib/k8s_deploy/.ssh/authorized_keys

hostnamectl set-hostname "$2"
echo "$1 $2" >> /etc/hosts
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg
apt-add-repository -y "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
snap install yq


if [[ $3 == "master" ]]; then
    kubeadm init --control-plane-endpoint=$1 --token 'imikl5.e5btaz7lhqfqvufm' 1> /dev/null;
    sleep 5
    mkdir -p $HOME/.kube;
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;
    chown $(id -u):$(id -g) $HOME/.kube/config;
    useradd -m -d /var/lib/k8s_user k8s_user; \
    echo "k8s_user ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/k8s_user; \
    mkdir -p /var/lib/k8s_user/.ssh; \
    echo $(cat k8s_user.pub) >> /var/lib/k8s_user/.ssh/authorized_keys; \
    chown k8s_user:k8s_user -R /var/lib/k8s_user; \
    chmod 700 /var/lib/k8s_user/.ssh/; \
    chmod 600 /var/lib/k8s_user/.ssh/authorized_keys
    ssh-keygen -b 2048 -t rsa -f k8s_user -N ""; \
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml;
    hash=$(cp /etc/kubernetes/admin.conf ~/admin.conf; echo $(yq eval '.clusters[0].cluster.certificate-authority-data' ~/admin.conf) | base64 -d | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex|awk '{print $2}'); \
    echo "insert at all additional nodes:  echo "$1 $2" >> /etc/hosts"
    echo "insert at worker node: kubeadm join $2:6443 --token imikl5.e5btaz7lhqfqvufm   --discovery-token-ca-cert-hash sha256:$hash"
    echo "insert at additional master node: kubeadm join $2:6443 --token imikl5.e5btaz7lhqfqvufm   --discovery-token-ca-cert-hash sha256:$hash --control-plane"
fi