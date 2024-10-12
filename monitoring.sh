#!/bin/bash

        # Architecture of the system
arch=$(uname -a)

        # Number of physical CPUs
socket=$(lscpu | grep "Socket" | awk '{print $2}')
cores_per_socket=$(lscpu | grep "socket" | awk '{print $4}')

total_cores=$((socket * cores_per_socket))

        #Number of virtual CPUs
vCPU=$(lscpu | grep "CPU(s):" | awk '{print $2}')

        #Memory usage (fraction and percentage)
total_mem=$(free --mega | grep "Mem" | awk '{print $2}')
used_mem=$(free --mega | grep "Mem" | awk '{print $3}')
mem_perc=$(echo "scale=2; $used_mem/$total_mem * 100" | bc -l)

        #CPU Load: we take it from top, for example (vmstat is also an option)
cpuload=$(top -bn1 | head -n 1 | grep "load average" | awk '{print $10}' | tr ',' '.')
cpuload=${cpuload::-1}
cpuload_perc=$(echo "scale=2; $cpuload * 100" | bc -l)

        #Last boot:
last_boot=$(who -b | awk '{$1=$1; print}')

        #LVM use
lvm_use=$(lsblk | grep "lvm" > /dev/null && echo "yes" || echo "no")

        #TCP connections
tcp_conn=$(netstat -nt | grep "ESTABLISHED" | wc -l)
established=$(netstat -nt | grep "ESTABLISHED" | awk '{print $6}' )

        #User log
user_log=$(users | wc -w)

        #Network: ip + MAC
ip=$(hostname -I)
mac=$(ip link |grep "ether" | awk '{print $2}')

        #Sudo commands
sudo_commands=$(cat /var/log/sudo/sudologs.log | grep "USER=root" | wc -l)

wall "
        - Architecture:         $arch
        - CPU physical:         $total_cores
        - vCPU:                 $vCPU
        - Memory usage:         $used_mem/$total_mem ($mem_perc%)
        - CPU load:             $cpuload_perc%
        - Last boot:            $last_boot
        - LVM use:              $lvm_use
        - TCP connections:      $tcp_conn $established
        - User log:             $user_log
        - Network:              IP $ip ($mac)
        - Sudo commands:        $sudo_commands
"
