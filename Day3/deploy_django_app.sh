#!/bin/bash

echo "**************** DEPLOYMENT STARTED ********************"

code_clone() {
    echo "Cloning the Django app..."
    git clone https://github.com/LondheShubham153/django-notes-app.git
}

install_requirements() {
    echo "Installing dependencies"
    sudo apt-get update
    sudo apt-get install -y docker.io nginx docker-compose
}

required_restarts() {
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl enable nginx
    sudo systemctl restart docker
    sudo systemctl restart nginx
}

deploy() {
    cd django-notes-app || exit 1
    sudo docker-compose up -d --build
}

if ! code_clone; then
    if [ -d "django-notes-app" ]; then
        echo "The code dir already exists"
    else
        echo "git clone failed"
        exit 1
    fi
fi

if ! install_requirements; then
    echo "Installation failed"
    exit 1
fi

if ! required_restarts; then
    echo "System fault identified"
    exit 1
fi

if ! deploy; then
    exit 1
fi

echo "**************** DEPLOYMENT DONE ***********************"
