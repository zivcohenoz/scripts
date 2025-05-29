#!/bin/bash
###########################################################
# Update Timezone
###########################################################
timedatectl set-timezone Asia/Jerusalem && timedatectl

###########################################################
# Set hostname for each machine
###########################################################
echo "Setting up hostname..."
read -p "Enter the hostname for this machine: " hostname
if [ -z "$hostname" ]; then
  hostname=$(hostname -s) # Use the current hostname if none is provided
  # echo "Hostname cannot be empty. Exiting."
  #  exit 1
fi
# Set the hostname and update /etc/hosts
echo "Setting hostname to '$hostname'..."
sudo hostnamectl set-hostname "$hostname"
echo "Hostname set to '$hostname'."
echo "[Done]"

###########################################################
# Update /etc/hosts file
###########################################################
echo "Updating /etc/hosts file..."
sudo sed -i "s/127\.0\.1\.1.*/127.0.1.1\t$hostname/" /etc/hosts
sudo cat /etc/hosts
echo "[Done]]"

###########################################################
# Disable swap for better performance
###########################################################
echo "Disabling swap..."
sudo sed -i '/swap/s/^/#/' /etc/fstab
sudo cat /etc/fstab
sudo swapoff -a
sudo swapon --show # Verify that swap is disabled
echo "Swap is now disabled."

###########################################################
# Apply any updates
###########################################################
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y
# sudo reboot
sudo apt install -y apt-transport-https ca-certificates curl gnupg gnupg2
echo "System packages updated. You may need to reboot for changes to take effect."


###########################################################
# Add settings to containerd.conf
# overlay (for using overlayfs), 
# br_netfilter (for ipvlan, macvlan, external SNAT of service IPs)
#
# ** br_netfilter is crucial for Docker and Kubernetes environments where containers or VMs are connected to a bridge network Kubernetes: Kubeadm has a preflight check for br_netfilter and bridge-nf-call-iptables=1, which is necessary for the kube-proxy component to function correctly when containers are connected to a Linux bridge. 
###########################################################
echo "Configuring containerd and kernel modules..."
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
echo "Kernel modules loaded."

###########################################################
# Configure sysctl settings for Kubernetes
###########################################################
echo "Configuring sysctl settings for Kubernetes..."

# Allow IPv4, IPv6 and IP forwarding
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
echo "Sysctl settings for Kubernetes configured."

# Reload updated config
echo "Reloading sysctl settings..."
sudo sysctl --system # Load the new modules
sysctl net.ipv4.ip_forward # Verify that IP forwarding is enabled
echo "IP forwarding is enabled."


###########################################################
# Install k8s components
###########################################################
echo "Installing k8s components..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

# Then, install Kubernetes components
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
# sudo apt-mark hold kubelet kubeadm kubectl # Prevent automatic updates of Kubernetes components

# Enable and start kubelet service
sudo systemctl enable --now kubelet # Start kubelet service

###########################################################
# Install containerd
###########################################################
echo "Installing containerd..."
sudo apt install -y containerd
# Configure containerd
# Create default configuration file for containerd
sudo mkdir /etc/containerd
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd


###########################################################
# Verify installation
###########################################################
kubeadm version                     # Check if kubeadm is installed
kubectl version --client            # Check if kubectl is installed
kubelet --version                   # Check if kubelet is installed
#sudo systemctl status kubelet       # Check if kubelet is running
#sudo systemctl status containerd    # Check if containerd is running

echo "Kubernetes components installed and running."
###########################################################

echo "Installation and configuration complete."
exec bash && exit # Reload the shell to apply the new hostname





###
# Initial setup for Kubernetes cluster:
# 1. **Initialize the Kubernetes Cluster:**
#    ```bash
#    kubeadm init --upload-certs --config kubeadm-config.yaml
#    ```
# 2. **Set up kubeconfig for the root user Optinal to add it into ~/.bashrc for auto load :**-
#    ```bash
#    mkdir -p $HOME/.kube
#    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#    sudo chown $(id -u):$(id -g) $HOME/.kube/config
#    ```
# 3. **Install a Pod Network Add-on:**
#    For example, using Calico:
#    ```bash
#     kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/operator-crds.yaml
#     kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/tigera-operator.yaml
#     # Download the custom resources necessary to configure Calico:
#     curl https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/custom-resources.yaml -O
#    
#     # Now Edit the custom-resources.yaml file to set the correct CIDR for your cluster:
#     nano custom-resources.yaml

#     # Apply the custom resources:
#     kubectl create -f custom-resources.yaml

#     # Verify the installation:
#     watch kubectl get pods -n calico-system
#    ```

# 4. **Join Worker Nodes to the Cluster:**
#    - On each worker node, run the command provided by `kubeadm init` on the master node.
#    ```bash
#    kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
#    ```
# 5. **Verify the Cluster Status:**
#    ```bash
#    kubectl get nodes
#    kubectl get pods --all-namespaces
#    ```
# 6. **Install Helm (optional):**
#    ```bash
#    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
#    helm repo add stable https://charts.helm.sh/stable
#    helm repo update
#    ```

###

