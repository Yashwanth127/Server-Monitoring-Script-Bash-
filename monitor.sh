#!/bin/bash

##############################################
# Linux Server Monitoring Dashboard VERSION="v1.0"
# Author : Yashwanth Kumar S
##############################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

draw_bar() {
    local value=$1
    local bars=$((value / 5))

    printf "["

    for ((i=0;i<20;i++))
    do
        if [ $i -lt $bars ]
        then
            printf "█"
        else
            printf "░"
        fi
    done

    printf "] %s%%\n" "$value"
}

clear

echo -e "${CYAN}"
echo "==============================================================="
echo "             LINUX SERVER MONITOR DASHBOARD VERSION="v1.0"  "
echo "==============================================================="
echo -e "${NC}"

echo -e "${WHITE}Date & Time :${NC} $(date)"
echo -e "${WHITE}Hostname    :${NC} $(hostname)"
echo -e "${WHITE}User        :${NC} $(whoami)"
echo -e "${WHITE}Operating System :${NC} $(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)"
echo -e "${WHITE}Kernel Version   :${NC} $(uname -r)"
echo

echo -e "${GREEN}Project Status : Dashboard Loaded Successfully ✔${NC}"

echo
echo "Welcome to the Server Monitoring Project!"
echo
echo "Developed by:Yashwanth Kumar S"
echo
#############################################################
# CPU Usage
#############################################################

echo -e "${BLUE}================ CPU USAGE ================${NC}"

cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

printf "CPU Usage : %.1f%%\n" "$cpu_usage"

cpu_int=$(printf "%.0f" "$cpu_usage")
draw_bar "$cpu_int"

if (( $(echo "$cpu_usage < 50" | bc -l) ))
then
    echo -e "${GREEN}Status : Healthy ✔${NC}"

elif (( $(echo "$cpu_usage < 80" | bc -l) ))
then
    echo -e "${YELLOW}Status : Moderate ⚠${NC}"

else
    echo -e "${RED}Status : High Usage ✘${NC}"
fi
#############################################################
# Memory Usage
#############################################################

echo
echo -e "${BLUE}============== MEMORY USAGE ===============${NC}"

mem_total=$(free -m | awk '/Mem:/ {print $2}')
mem_used=$(free -m | awk '/Mem:/ {print $3}')
mem_free=$(free -m | awk '/Mem:/ {print $4}')

mem_usage=$(awk "BEGIN {printf \"%.1f\", ($mem_used/$mem_total)*100}")

echo "Total Memory : ${mem_total} MB"
echo "Used Memory  : ${mem_used} MB"
echo "Free Memory  : ${mem_free} MB"
echo "Memory Usage : ${mem_usage}%"
mem_int=$(printf "%.0f" "$mem_usage")
draw_bar "$mem_int"
if (( $(echo "$mem_usage < 50" | bc -l) ))
then
    echo -e "${GREEN}Status : Healthy ✔${NC}"

elif (( $(echo "$mem_usage < 80" | bc -l) ))
then
    echo -e "${YELLOW}Status : Moderate ⚠${NC}"

else
    echo -e "${RED}Status : High Memory Usage ✘${NC}"
fi
#############################################################
# Disk Usage
#############################################################

echo
echo -e "${BLUE}=============== DISK USAGE ================${NC}"

disk_usage=$(df -h / | awk 'NR==2 {gsub("%",""); print $5}')
disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_total=$(df -h / | awk 'NR==2 {print $2}')
disk_free=$(df -h / | awk 'NR==2 {print $4}')

echo "Total Disk  : $disk_total"
echo "Used Disk   : $disk_used"
echo "Free Disk   : $disk_free"
echo "Disk Usage  : ${disk_usage}%"
draw_bar "$disk_usage"
if [ "$disk_usage" -lt 50 ]
then
    echo -e "${GREEN}Status : Healthy ✔${NC}"

elif [ "$disk_usage" -lt 80 ]
then
    echo -e "${YELLOW}Status : Moderate ⚠${NC}"

else
    echo -e "${RED}Status : Disk Almost Full ✘${NC}"
fi
#############################################################
# System Uptime
#############################################################

echo
echo -e "${BLUE}============= SYSTEM UPTIME =============${NC}"

echo "System Uptime : $(uptime -p)"

echo "Load Average  : $(uptime | awk -F'load average:' '{print $2}')"
#############################################################
# Network Information
#############################################################

echo
echo -e "${BLUE}=========== NETWORK INFORMATION ===========${NC}"

ip_address=$(hostname -I | awk '{print $1}')

echo "IP Address : $ip_address"

if ping -c 1 google.com > /dev/null 2>&1
then
    echo -e "${GREEN}Internet : Connected ✔${NC}"
else
    echo -e "${RED}Internet : Not Connected ✘${NC}"
fi
#############################################################
# Running Services
#############################################################

echo
echo -e "${BLUE}============ RUNNING SERVICES ============${NC}"

services=("ssh" "cron" "NetworkManager")

for service in "${services[@]}"
do
    if systemctl is-active --quiet "$service"
    then
        echo -e "$service : ${GREEN}Running ✔${NC}"
    else
        echo -e "$service : ${RED}Not Running ✘${NC}"
    fi
done
#############################################################
# Top CPU Processes
#############################################################

echo
echo -e "${BLUE}========== TOP CPU PROCESSES ==========${NC}"

ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6
#############################################################
# Top Memory Processes
#############################################################

echo
echo -e "${BLUE}========= TOP MEMORY PROCESSES =========${NC}"

ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -6

#############################################################
# Logging
#############################################################

mkdir -p logs

LOGFILE="logs/monitor.log"

echo "=========================================" >> "$LOGFILE"
echo "Date & Time : $(date)" >> "$LOGFILE"
echo "CPU Usage   : ${cpu_usage}%" >> "$LOGFILE"
echo "Memory Usage: ${mem_usage}%" >> "$LOGFILE"
echo "Disk Usage  : ${disk_usage}%" >> "$LOGFILE"
echo "IP Address  : $ip_address" >> "$LOGFILE"
echo "=========================================" >> "$LOGFILE"
echo "" >> "$LOGFILE"

#############################################################
# Footer
#############################################################

echo
echo -e "${CYAN}===============================================================${NC}"
echo -e "${WHITE}      Linux Server Monitoring Dashboard ${VERSION}${NC}"
echo -e "${WHITE}      Last Updated : $(date)${NC}"
echo -e "${CYAN}===============================================================${NC}"
