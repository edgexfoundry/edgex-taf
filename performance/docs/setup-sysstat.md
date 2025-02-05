
# Setup Sysstat

This guide provides step-by-step instructions to manually install, configure, and schedule `sysstat` for collecting system performance data every 10 minutes.

---
## Option 1: Run Setup Automatically (Using a Script)
If you want a quick and automated setup, you can use the following script to install and configure sysstat automatically.

1. Navigate to the `edgex-taf/performance` directory.
2. Run the following command to execute the script:
   ```bash
   sudo ./setup_sysstat.sh
   ```


## Option 2: Manual Setup
### Step 1: Install Sysstat
1. Update the package list:
   ```bash
   sudo apt-get update
   ```
2. Install `sysstat`:
   ```bash
   sudo apt-get install -y sysstat
   ```

---

### Step 2: Enable Sysstat Data Collection
1. Open the sysstat configuration file:
   ```bash
   sudo nano /etc/default/sysstat
   ```
2. Replace the line `ENABLED="false"` with `ENABLED="true"`
3. Restart sysstat
   ```bash
   sudo systemctl restart sysstat
   ```
---

### Step 3: Configure Data Collection Interval
By default, sysstat collects performance data every **10 minutes**.
This is controlled by a cron job in `/etc/cron.d/sysstat`.
The default cron job looks like this:

```bash
5-55/10 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1
```

Note: Replace debian-sa1 with sa1 to ensure data collection works properly:

```bash
*/10 * * * * root command -v sa1 > /dev/null && sa1 1 1
```

Save the file and restart the cron service:
```bash
sudo systemctl restart cron
```

This means:
- Sysstat collects a single sample (`1 1`) every 10 minutes (`*/10`).
- Follows the [Cron](https://en.wikipedia.org/wiki/Cron) syntax, to schedule the sysstat job
---


## Verify Configuration
1. Confirm sysstat is collecting data every 10 minutes:
   ```bash
   sar -u 1 3
   ```
   This shows CPU usage sampled every second for three intervals.

---

## View Report Using SAR Charts
1. Export a SAR file
   ```bash
   sar -A -p -f /var/log/sysstat/saXX > /tmp/saXX_$(uname -n).txt
   ```
   Replace XX with the day of sysstat export.

2. Go to [SAR Charts](https://sarcharts.tuxfamily.org) website
3. Upload the exported file:
   - Choose the file `/tmp/saXX_$(uname -n).txt`
   - Click `Submit`.
4. The report will display in your browser.


Alternative SAR Charts site:
🔹 [SAR Chart by Dotsuresh](https://sarchart.dotsuresh.com/)

---

## Summary
- **Sysstat Installation**: Installed using `apt-get`.
- **10-Minute Data Collection**: Configured in `/etc/cron.d/sysstat`.

With this setup, sysstat collects detailed system performance data every 10 minutes for analysis.
Additionally, you can visualize reports using SAR Charts.
