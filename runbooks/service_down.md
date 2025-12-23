# Runbook: Service Down Alert

## 🚨 Trigger
This alert is triggered when a critical service defined in `config/services.conf` is found to be inactive (`systemctl is-active` returns non-zero).

## 🛑 Impact
- Service unavailability (e.g., Web server down, SSH inaccessible).
- Potential downstream failures if other services depend on it.

## 🤖 Automated Remediation
The `remediate.sh` script automatically attempts the following:
1.  **Restart Service**: Executes `systemctl restart <service_name>`.
2.  **Verification**: Checks immediately after restart if the service is active.
3.  **Logging**: Logs the success or failure of the restart attempt.

## 🛠️ Manual Investigation & Resolution

If the automated restart fails (alert log shows "FAILURE"):

1.  **Check Service Status Details**:
    ```bash
    systemctl status <service_name> -l
    ```
2.  **Inspect Service Logs**:
    Read the specific logs for the application to find the root cause (config error, port conflict, etc.).
    ```bash
    journalctl -u <service_name> --no-pager | tail -n 50
    ```
3.  **Test Configuration**:
    If it's a web server like Nginx or Apache, test the config file syntax:
    ```bash
    nginx -t
    # or
    apachectl configtest
    ```
4.  **Resource Constraints**:
    Check if the service was killed due to OOM (Out Of Memory):
    ```bash
    dmesg | grep -i "killed process"
    ```
