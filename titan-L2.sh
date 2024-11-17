# !/bin/bash

curl -s https://raw.githubusercontent.com/CryptoBureau01/logo/main/logo.sh | bash
sleep 5

# Function to print info messages
print_info() {
    echo -e "\e[32m[INFO] $1\e[0m"
}

# Function to print error messages
print_error() {
    echo -e "\e[31m[ERROR] $1\e[0m"
}



#Function to check system type and root privileges
master_fun() {
    echo "Checking system requirements..."

    # Check if the system is Ubuntu
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            echo "This script is designed for Ubuntu. Exiting."
            exit 1
        fi
    else
        echo "Cannot detect operating system. Exiting."
        exit 1
    fi

    # Check if the user is root
    if [ "$EUID" -ne 0 ]; then
        echo "You are not running as root. Please enter root password to proceed."
        sudo -k  # Force the user to enter password
        if sudo true; then
            echo "Switched to root user."
        else
            echo "Failed to gain root privileges. Exiting."
            exit 1
        fi
    else
        echo "You are running as root."
    fi

    echo "System check passed. Proceeding to package installation..."
}


# Function to install dependencies
install_dependency() {
    print_info "<=========== Install Dependency ==============>"
    print_info "Updating and upgrading system packages, and installing curl..."
    sudo apt update && sudo apt upgrade -y && sudo apt install git wget jq curl -y 

    # Check if Docker is install
    print_info "Installing Docker..."
    # Download and run the custom Docker installation script
     wget https://raw.githubusercontent.com/CryptoBureau01/packages/main/docker.sh && chmod +x docker.sh && ./docker.sh
     # Check for installation errors
     if [ $? -ne 0 ]; then
        print_error "Failed to install Docker. Please check your system for issues."
        exit 1
     fi
     # Remove the docker.sh file after installation
     rm -f docker.sh


    # Docker Composer Setup
    print_info "Installing Docker Compose..."
    # Download and run the custom Docker Compose installation script
    wget https://raw.githubusercontent.com/CryptoBureau01/packages/main/docker-compose.sh && chmod +x docker-compose.sh && ./docker-compose.sh
    # Check for installation errors
    if [ $? -ne 0 ]; then
       print_error "Failed to install Docker Compose. Please check your system for issues."
       exit 1
    fi
    # Remove the docker-compose.sh file after installation
    rm -f docker-compose.sh

    # Print Docker and Docker Compose versions to confirm installation
    print_info "Checking Docker version..."
    docker --version

     print_info "Checking Docker Compose version..."
     docker-compose --version

    # Call the uni_menu function to display the menu
    master
}



# Function to set up the Titan Node
setup_node() {
  echo "Starting Titan Node setup..."

  # Step 1: Create a directory for Titan Node setup
  NODE_DIR=~/titan-node
  echo "Creating directory: $NODE_DIR"
  mkdir -p $NODE_DIR
  cd $NODE_DIR
  sleep 1
  
  # Step 2: Download Titan Node CLI
  CLI_URL="https://github.com/Titannet-dao/titan-node/releases/download/v0.1.20/titan-edge_v0.1.20_246b9dd_linux-amd64.tar.gz"
  echo "Downloading Titan Node CLI from $CLI_URL"
  wget $CLI_URL
  sleep 1

  
  # Step 3: Extract the downloaded file
  TAR_FILE="titan-edge_v0.1.20_246b9dd_linux-amd64.tar.gz"
  echo "Extracting $TAR_FILE"
  tar -zxvf $TAR_FILE
  sleep 1

  # Step 4: Enter the extracted folder
  EXTRACTED_DIR="titan-edge_v0.1.20_246b9dd_linux-amd64"
  echo "Entering directory: $EXTRACTED_DIR"
  cd $EXTRACTED_DIR
  sleep 1

  # Step 5: Copy the binary to /usr/local/bin
  echo "Copying titan-edge binary to /usr/local/bin"
  sudo cp titan-edge /usr/local/bin
  sleep 1

  # Step 6: Copy the library to /usr/local/lib
  LIBRARY_FILE="libgoworkerd.so"
  echo "Copying $LIBRARY_FILE to /usr/local/lib"
  sudo cp $LIBRARY_FILE /usr/local/lib
  sleep 1

  echo "Titan Node setup completed successfully!"

  # Call the uni_menu function to display the menu
  master
}



# Function to launch the Titan Node
launch_node() {
  echo "Launching Titan Node..."

  # Step 1: Set the LD_LIBRARY_PATH environment variable
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
  echo "LD_LIBRARY_PATH set to: $LD_LIBRARY_PATH"
  sleep 1

  # Step 2: Start the Titan Edge daemon
  DAEMON_URL="https://cassini-locator.titannet.io:5000/rpc/v0"
  echo "Starting Titan Edge daemon with URL: $DAEMON_URL"

  # Capture the output and logs of the start command
  # Run the titan-edge daemon in the background and capture logs
  titan-edge daemon start --init --url $DAEMON_URL > /root/titan-node/titan_node.log 2>&1 &

  # Log the output to a log file
  LOG_FILE="/root/titan-node/titan_node.log"
  
  # Check if the directory exists, if not create it
  if [ ! -d "/root/titan-node" ]; then
    mkdir -p /root/titan-node
  fi

  sleep 1
  # Save logs to the log file
  echo "Saving launch logs to $LOG_FILE"
  echo "Titan Node Launch Logs:" > "$LOG_FILE"

  # Sleep a bit to allow the daemon to start and log some information
  sleep 3

  # Echo the latest logs from the log file to give user some feedback
  tail -n 20 "$LOG_FILE" 

  echo "Titan Node launched successfully!"

  # Call the uni_menu function to display the menu
  master
}





# Function to bind the Titan account
bind_code() {
  echo "Binding Titan Account..."

  # Path to the data file
  DATA_FILE="/root/titan-node/data.txt"

  # Check if the file already exists and contains a BindCode
  if [ -f "$DATA_FILE" ]; then
    if grep -q "BindCode=" "$DATA_FILE"; then
      echo "BindCode is already saved in $DATA_FILE. No changes made."
      return  # Exit the function
    fi
  fi

  sleep 1
  # Step 1: Prompt user for the Titan account identification code
  read -p "Enter your Titan account identification code: " BIND_CODE

  # Step 2: Save the BindCode to the file
  echo "Saving BindCode to $DATA_FILE"
  mkdir -p "$(dirname "$DATA_FILE")" # Ensure directory exists
  echo "BindCode=$BIND_CODE" >"$DATA_FILE"
  
  sleep 1
  # Step 3: Bind the Titan account using the provided BindCode
  echo "Binding Titan account with Device: $BIND_CODE"
  titan-edge bind --hash="$BIND_CODE" https://api-test1.container1.titannet.io/api/v2/device/binding

  echo "Titan Account BindCode saved successfully!"
  # Call the uni_menu function to display the menu
  master
}



check_logs() {
  echo "Checking Titan Node Logs..."

  # Path to the log file
  LOG_FILE="/root/titan-node/titan_node.log"

  # Check if the log file exists
  if [ -f "$LOG_FILE" ]; then
    echo "Displaying logs from $LOG_FILE:"
    cat "$LOG_FILE"  # Display the contents of the log file
  else
    echo "Log file $LOG_FILE does not exist. No logs found."
  fi

  # Call the uni_menu function to display the menu
  master
}


refresh_node() {
  echo "Refreshing Titan Node..."

  # Step 1: Stop the Titan Node
  echo "Stopping Titan Node..."
  titan-edge daemon stop

  sleep 1
  # Step 2: Start the Titan Node again
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
  echo "LD_LIBRARY_PATH set to: $LD_LIBRARY_PATH"
  sleep 1

  # Step 3: Start the Titan Edge daemon
  DAEMON_URL="https://cassini-locator.titannet.io:5000/rpc/v0"
  echo "Starting Titan Edge daemon with URL: $DAEMON_URL"

  # Capture the output and logs of the start command
  titan-edge daemon start --init --url $DAEMON_URL > /root/titan-node/titan_node.log 2>&1 &
  # Log the output to a log file
  LOG_FILE="/root/titan-node/titan_node.log"
  
  # Check if the directory exists, if not create it
  if [ ! -d "/root/titan-node" ]; then
    mkdir -p /root/titan-node
  fi

  sleep 1
  # Save logs to the log file
  echo "Saving launch logs to $LOG_FILE"
  echo "Titan Node Launch Logs:" > "$LOG_FILE"
  echo "$start_logs" >> "$LOG_FILE"

  echo "Titan Node refreshed successfully!"

  # Call the uni_menu function to display the menu
  master
  
}


stop_node() {
  echo "Stopping Titan Node..."

  # Command to stop the Titan Edge daemon
  titan-edge daemon stop

  echo "Titan Node has been stopped successfully!"

  # Call the uni_menu function to display the menu
  master
}





# Function to display menu and prompt user for input
master() {
    print_info "====================================="
    print_info "   Titan-L2 EDGE Node Tool Menu      "
    print_info "====================================="
    print_info ""
    print_info "1. Install-Dependency"
    print_info "2. Setup-Titan"
    print_info "3. Launch-Node"
    print_info "4. Bind-Code"
    print_info "5. Logs-Check"
    print_info "6. Refresh-Node"
    print_info "7. Stop-Node"
    print_info "8. Exit"
    print_info ""
    print_info "==============================="
    print_info " Created By : CB-Master "
    print_info "==============================="
    print_info ""
    
    read -p "Enter your choice (1 or 8): " user_choice

    case $user_choice in
        1)
            install_dependency
            ;;
        2)
            setup_node
            ;;
        3) 
            launch_node
            ;;
        4)
            bind_code
            ;;
        5)
            check_logs
            ;;
        6)
            refresh_node
            ;;
        7)
            stop_node
            ;;
        8)
            exit 0  # Exit the script after breaking the loop
            ;;
        *)
            print_error "Invalid choice. Please enter 1 or 8 : "
            ;;
    esac
}

# Call the uni_menu function to display the menu
master_fun
master
