#!/usr/bin/env bash

# Output file
output_file="metrics.txt"
freespace=$(df -h / | awk 'NR==2 {print $4}')
freememory=$(free -h | awk 'NR==2 {print $4}')

logdate=$(date +'%Y-%m-%d')
check_logs() {

	echo -e "\nLog Check:" >> "$output_file"

	log_file="/var/log/syslog"

	if [[ -e $log_file ]]; then
		error_count=$(grep -ic "error" "$log_file")
		echo "Setting error count to number of times the word "error" occures in the log file."

		if ["error_count" -gt 0 ]; then
			echo "Errors found in $log_file. Count: $error_count" >> "$output_file"
		else
			echo "No errors found in $log_file." >> "$output_file"
		fi
	else
		echo -e "\tFile does not exist" >> "$output_file"
	fi
}

check_services(){
	echo -e "\nServices Status:" >> "$output_file"

	service_name="dbus"
	if service "$service_name" status &> error.txt; then
		echo -e "\t$service_name is running." >> "$output_file"
	else
		echo "$service_name is not running." >> "$output_file"

	fi
}

check_system_metrics(){
	echo -e "\nSystem Metrics:" >> "$output_file"

	cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
	echo -e "\tCPU Usage: $cpu_usage%" >> "$output_file"

	memory_usage=$(free -m | awk '/Mem/ {print $3}')
	echo -e "\tMemory Usage: ${memory_usage}MB" >> "$output_file"

	disk_space=$(df -h / | awk '/\// {print $5}')
	echo -e "\tDisk Space Usage: $disk_space" >> "$output_file"

}

check_system_info(){
	echo -e "\nSystem Information:" >> "$output_file"
	
	kernel_release=$(uname -r)
	echo -e "\tKernel Release:\t $kernel_release" >> "$output_file"
	
	bash_version=$BASH_VERSION
	echo -e "\tBash Version:\t $bash_version" >> "$output_file"


	echo -e "\tFree Storage:\t $freespace" >> "$output_file"

	echo -e "\tFree Memory:\t $freememory" >> "$output_file"

	pwdfiles=$(ls | wc -l)
	echo -e "\tFiles in pwd:\t $pwdfiles" >> "$output_file"

	echo -e "\tGenerated on:\t $logdate" >> "$output_file"
}

generate_metrics(){
	check_system_info
	check_logs
	check_services
	check_system_metrics
}
# This line clears existing content
# in the output file
> "$output_file"
generate_metrics
