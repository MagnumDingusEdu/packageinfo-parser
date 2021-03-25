import subprocess

# Run the script
# Does not log output for now
rc = subprocess.call("./get_packages.sh", shell=True)
