# Runbook: High Disk Usage Alert

## 🚨 Trigger
This alert is triggered when the root filesystem `/` usage exceeds the configured threshold (default: **85%**).

## 🛑 Impact
- System instability.
- Inability to write new logs.
- Potential service crashes (e.g., database lockups).

## 🤖 Automated Remediation
The `remediate.sh` script automatically attempts the following:
1.  **Clean `/tmp`**: Removes all files in the temporary directory.
2.  **Vacuum Logs**: Reduces `systemd` journal logs to retain only the last 2 days.
3.  **Clean Cache**: Caches from package managers (apt/yum) are cleared.

## 🛠️ Manual Investigation & Resolution

If the automated remediation fails to lower disk usage:

1.  **Identify Large Files**:
    ```bash
    du -ah / | sort -rh | head -n 20
    ```
2.  **Check Docker Overlay (if applicable)**:
    Docker can consume significant space. Prune unused images/containers:
    ```bash
    docker system prune -a
    ```
3.  **Check Log Files**:
    Sometimes application logs (e.g., in `/var/log/nginx/`) grow indefinitely.
    ```bash
    ls -lh /var/log/
    ```
4.  **Expand Storage**:
    If the data is legitimate, consider resizing the EBS volume or adding a new partition.
