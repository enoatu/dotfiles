# docker メモリ制限
```
sudo tee /etc/systemd/system/docker-limit.slice > /dev/null <<'EOF'
[Unit]
Description=Limited slice for Docker containers
Before=slices.target

[Slice]
MemoryAccounting=true
MemoryMax=20G
MemoryHigh=15G
CPUAccounting=true
EOF

# daemon.json
vim /etc/docker/daemon.json

```json
{
  ...
  "cgroup-parent": "docker-limit.slice"
}
```
sudo systemctl daemon-reload
sudo systemctl start docker-limit.slice
sudo systemctl status docker-limit.slice
```
