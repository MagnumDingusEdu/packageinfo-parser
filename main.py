import subprocess
from typing import List

# Run the script
# Does not log output for now
rc = subprocess.call("./get_packages.sh", shell=True)

with open('arch_list.txt') as f:
    archlinux_repo_list: List[str] = f.readlines()

with open('fedora_list.txt') as f:
    fedora_repo_list: List[str] = f.readlines()

with open('ubuntu_list.txt') as f:
    ubuntu_repo_list: List[str] = f.readlines()


class Package:
    name: str
    version: str
    repository: str
    distribution: str
    architecture: str


