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









# Function to display menu and prompt user for input
master() {
    print_info "====================================="
    print_info "   Titan-L2 EDGE Node Tool Menu      "
    print_info "====================================="
    print_info ""
    print_info "1. Install-Dependency"
    print_info "2. Setup-Titan"
    print_info "3. "
    print_info "4. "
    print_info "5. "
    print_info "6. "
    print_info "7. "
    print_info "8. "
    print_info "9. "
    
    print_info ""
    print_info "==============================="
    print_info " Created By : CB-Master "
    print_info "==============================="
    print_info ""
    
    read -p "Enter your choice (1 or 3): " user_choice

    case $user_choice in
        1)
            install_dependency
            ;;
        2)
            setup_node
            ;;
        3) 

            ;;
        4)

            ;;
        5)

            ;;
        6)

            ;;
        7)

            ;;
        8)
            exit 0  # Exit the script after breaking the loop
            ;;
        *)
            print_error "Invalid choice. Please enter 1 or 3 : "
            ;;
    esac
}

# Call the uni_menu function to display the menu
master_fun
master
