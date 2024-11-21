#Function to install required applications

install_apps(){
for app in sshpass nmap whois torify; do
if ! command -v $app &> /dev/null; then
echo "$app not found, installing..."
sudo apt-get install -y $app

else

echo "$app is already installed."
fi
done
}

#Function to check if the network is anonymous

check_anonymity(){

#Placeholder for actual anonymity check logic
#For demonstration, let's assure it returns as a spoofed country name.
ANON_FLAG=1 # 1 means anonymous, 0 means not anonymous

if [$ANON_FLAG -eq 0]; then
echo "Network is not anonymous. Exiting..."
exit 1

else
SPOOFED_COUNTRY="FakeCountry" #Replace with actual logic to get spoofed country
echo "Anonymous network detected. Spoofed Country: $SPOOFED_COUNTRY"
fi

}

#Function to connect to the remote server and execute commands

connect_remote(){
REMOTE_SERVER="user@10.12.74.166" # The provided IP address
echo "Connecting to $REMOTE_SERVER..."

echo "Getting server details"

#Display remote server details

sshpass -p 'rca' ssh -o StrictHostKeyChecking=no $REMOTE_SERVER "echo 'Country: \$(curl -s ipinfo.io/country)'; echo 'IP: \$(curl -s ifconfig.me)'; echo 'Uptime: \$(uptime)'"

if [$? -ne 0]; then 
echo "Failed to connect to the remote server."
exit 1
fi


#Execute commands on the remote server

echo "Checking Whois for the given address..."
read -p "Enter the address to scan:" ADDRESS
sshpass -p 'rca' ssh $REMOTE_SERVER "whois $ADDRESS > whois_output.txt"

if [$? -ne 0]; then
echo "Failed to execute whois command."
exit 1

fi

echo "Scanning open ports on the given address..."
sshpass -p 'rca' ssh $REMOTE_SERVER "nmap $ADDRESS > nmap_output.txt"

if [$? -ne 0]; then
echo "Failed to execute nmap command."
exit 1

fi

}

#Function to save results and create logs

save_results(){
echo "Saving results to local files..."
scp $REMOTE_SERVER:whois_output.txt ./whois_output.txt
scp $REMOTE_SERVER:nmap_output.txt ./nmap_output.txt
echo "Results saved locally."

#Create a log
echo "$(date): Whois and Nmap scan completed for $ADDRESS." >>scan_log.txt
}

#Main function to orchestrate the tasks

main(){
install_apps
check_anonymity
connect_remote
save_results
}

#Execute the main functiom
main