curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo apt update
sudo apt install unzip -y

unzip awscliv2.zip

sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin --update

aws --version

aws configure