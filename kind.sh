#!/bin/bash
INSTALL_DIR="/usr/local/bin"

KIND_URL="https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64"

wget -O $INSTALL_DIR/kind $KIND_URL

chmod +x $INSTALL_DIR/kind

# Check if Kind installation was successful
if [ $? -eq 0 ]; then
    echo "Kind installed successfully!"

    # Log in to Docker
    echo "Logging in to Docker..."
    docker login

    # Check if Docker login was successful
    if [ $? -eq 0 ]; then
        echo "Docker login successful!"

        # Create a Kind Cluster
        echo "Creating Kind cluster ..."
        kind create cluster

        # Check if cluster creation was successful
        if [ $? -eq 0 ]; then
            echo "Kind cluster created successfully!"
        else
            echo "Error: Kind cluster creation failed."
            exit 1
        fi
    else
        echo "Error: Docker login failed."
        exit 1
    fi
else
    echo "Error: Kind installation failed."
    exit 1
fi
