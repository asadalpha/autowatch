# 🦅 AutoWatch: Automated System Monitoring & Remediation

AutoWatch is a lightweight, self-healing infrastructure monitoring tool designed for SREs and System Administrators. It monitors system resources (CPU, Memory, Disk) and critical services, automatically attempting remediation and logging alerts when thresholds are breached.

## 📂 Project Structure

```
autowatch/
├── bin/
│   ├── monitor.sh       # Main logic: checks metrics vs thresholds
│   └── remediate.sh     # Action scripts: cleans disk, restarts services
├── config/
│   ├── thresholds.conf  # Define limits for CPU, RAM, Disk
│   └── services.conf    # List of services to keep alive (nginx, ssh, etc.)
├── alerts/
│   └── notifier.py      # Python script to handle logging and notifications
├── cron/
│   └── autowatch.cron   # Cron job definition for continuous monitoring
├── logs/
│   ├── metrics.log      # Time-series data of system health
│   └── alerts.log       # History of incidents and remediation actions
├── runbooks/            # Documentation for manual incident resolution
└── setup.sh             # One-click installation script
```

## 🚀 Installation & Usage

1.  **Initialize the Environment**
    Run the setup script to create necessary directories and set permissions.
    ```bash
    ./setup.sh
    ```

2.  **Configure Thresholds**
    Edit `config/thresholds.conf` to set your desired limits.
    ```bash
    CPU_LIMIT=80
    MEM_LIMIT=75
    DISK_LIMIT=85
    ```

3.  **Define Critical Services**
    Add service names (as recognized by `systemctl`) to `config/services.conf`.
    ```text
    nginx
    docker
    cron
    ```

4.  **Run Manually**
    Test the monitoring script.
    ```bash
    ./bin/monitor.sh
    ```

5.  **Automate with Cron**
    Link the cron job to run every 2 minutes.
    ```bash
    crontab cron/autowatch.cron
    ```

## ⚙️ How It Works

1.  **Monitor**: `monitor.sh` gathers current system stats.
2.  **Evaluate**: Uses `bc` for precise floating-point comparison against config.
3.  **Alert**: If a threshold is breached, `notifier.py` logs the incident to `logs/alerts.log`.
4.  **Remediate**:
    *   **Disk Full**: Triggers `remediate.sh disk` to clean `/tmp` and vacuum logs.
    *   **Service Down**: Triggers `remediate.sh service <name>` to restart the failed service.

## 📝 Logs

*   **metrics.log**: `2025-12-23 20:00:00 cpu=12.5% mem=45.2% disk=60%`
*   **alerts.log**: `2025-12-23 20:05:00 [ALERT] CPU usage critical: 92%`

---
*Built for reliability.*
