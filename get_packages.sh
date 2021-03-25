#!/usr/bin/env bash

logfile=debug.log

# Clean data from previous runs
[ ! -e $logfile ] || rm $logfile
[ ! -e ubuntu_list.txt ] || rm ubuntu_list.txt
[ ! -e fedora_list.txt ] || rm fedora_list.txt
[ ! -e arch_list.txt ] || rm arch_list.txt

printf "Pulling the latest container images...\n"
docker pull ubuntu:latest &>>$logfile
echo -e "\xE2\x9C\x94 ubuntu"
docker pull fedora:latest &>>$logfile
echo -e "\xE2\x9C\x94 fedora"
docker pull archlinux:latest &>>$logfile
echo -e "\xE2\x9C\x94 archlinux"
printf "Finished.\n"

printf "Getting the package listings from respective package managers...\n"

#######################    FEDORA    ##############################
# Run the fedora container in detached mode
fedora_container_id=$(docker run -d fedora:latest sleep infinity)
# Speed up the updating process
docker exec "$fedora_container_id" /bin/bash -c 'printf "max_parallel_downloads=10\nfastestmirror=True\n" >> /etc/dnf/dnf.conf' &>>$logfile
# Get the package listing
docker exec "$fedora_container_id" /usr/bin/dnf list all --color=never >fedora_list.txt
# Clean up
docker kill "$fedora_container_id" &>>$logfile
docker rm "$fedora_container_id" &>>$logfile
echo -e "\xE2\x9C\x94 fedora"

########################   UBUNTU    ###############################
# Run the ubuntu container in detached mode
ubuntu_container_id=$(docker run -d ubuntu:latest sleep infinity)
# Update the repository listings
docker exec "$ubuntu_container_id" apt update &>>$logfile
# Get the package listing
docker exec "$ubuntu_container_id" apt list >ubuntu_list.txt
# Clean up
docker kill "$ubuntu_container_id" &>>$logfile
docker rm "$ubuntu_container_id" &>>$logfile
echo -e "\xE2\x9C\x94 ubuntu"

######################## ARCHLINUX ##################################
# Run the archlinux container in detached mode
arch_container_id=$(docker run -d archlinux:latest sleep infinity)
# Include the 32-bit repositories in listings
docker exec "$arch_container_id" /bin/bash -c 'printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf' &>>$logfile
# Update repositories
docker exec "$arch_container_id" pacman -Syy &>>$logfile
# Get the package listing
docker exec "$arch_container_id" pacman --color never -Sl >arch_list.txt
# Clean up
docker kill "$arch_container_id" &>>$logfile
docker rm "$arch_container_id" &>>$logfile
echo -e "\xE2\x9C\x94 archlinux"

# Clean up listings by deleting stray output
sed -i '1d' ubuntu_list.txt
sed -i "1,$(sed -n '/Installed Packages/=' fedora_list.txt)d" fedora_list.txt

printf "Fetching complete\n"
