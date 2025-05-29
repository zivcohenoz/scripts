# ONLY RUN THIS SCRIPT ON THE LOAD BALANCER NODE
1. **Install HAProxy:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y haproxy
   ```

2. **Configure HAProxy:**
   Edit the HAProxy configuration file (`/etc/haproxy/haproxy.cfg`):
   ```bash
   sudo nano /etc/haproxy/haproxy.cfg
   ```

   Add the following configuration:
   ```haproxy
frontend kubernetes-frontend
    bind *:6443
    option tcplog
    mode tcp
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    balance roundrobin
    option tcp-check
    server master1 10.10.10.10:6443 check
    server master2 10.10.10.13:6443 check
    server master3 10.10.10.14:6443 check
       
3. **Restart HAProxy:**
   ```bash
   sudo systemctl restart haproxy

###### HAProxy Setup Script for Kubernetes Cluster ######
# This script sets up HAProxy to load balance traffic to a Kubernetes cluster.
# It assumes you have three Kubernetes master nodes with IPs
# IMPORTANT: Replace the IPs with your actual master node IPs.
# this should run AFTER the Kubernetes cluster is set up and running.
4. **Configure HAProxy Stats:**
   - Add the stats configuration to `/etc/haproxy/haproxy.cfg`:
     
nano /etc/haproxy/haproxy.cfg

#Enter this to the end of the file

listen stats
    bind *:8404
    mode http
    stats enable
    stats uri /
    stats refresh 10s
    stats admin if LOCALHOST

# Now restart HAProxy to apply the changes
sudo systemctl restart haproxy