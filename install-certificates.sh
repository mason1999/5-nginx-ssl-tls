#! /usr/bin/bash

# Install tools first
function install_dependencies() {
    if ! { command -v mkcert; } > /dev/null; then
        sudo apt-get install -y libnss3-tools
        curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
        chmod +x mkcert-v*-linux-amd64
        sudo cp mkcert-v*-linux-amd64 "/usr/local/bin/mkcert"
        rm mkcert-v*-linux-amd64
    else
        echo "mkcert exists. No need to install."
    fi
}
getopts ":miucdlwh" option

case $option in
    (m) install_dependencies
        ;;
    (i) mkcert -install
        ;;
    (u) mkcert -uninstall
        sudo update-ca-certificates -f
        cert_directory=$(mkcert -CAROOT)
        rm -f "${cert_directory}/rootCA-key.pem"
        rm -f "${cert_directory}/rootCA.pem"
        ;;
    (l) cert_directory=$(mkcert -CAROOT)
        echo "certs in mkcert directory ${cert_directory}:"
        ls $cert_directory
        echo ''
        echo 'mkcert certs in /usr/local/share/ca-certificates:'
        ls /usr/local/share/ca-certificates | grep 'mkcert'
        echo ''
        echo 'mkcert certs in system trust /etc/ssl/certs:'
        ls /etc/ssl/certs | grep 'mkcert'
        ;;
    (c) mkdir -p certs
        mkcert -cert-file certs/public_cert.pem -key-file certs/private_key.pem example.com example.org localhost 127.0.0.1 ::1
        ;;
    (d) rm -rf certs
        ;;
    (w) cat <<'EOF'
For our windows host we need to do some extra steps.

1. We need to update the C:\Windows\System32\drivers\etc\hosts file with example.com, example.org, localhost, ::1. For example:
        127.0.0.1 example.com
        127.0.0.1 example.org
        127.0.0.1 localhost
        127.0.0.1 ::1

2. We need to copy the root certificate to our windows system. Something like: 
        root_dir=$(mkcert -CAROOT) && cp -r "${root_dir}/rootCA.pem /mnt/c/Users/<user>/..."

3. Open up the cert manager tool on your windows host: search 
        "Manage user certificates > Trusted Root Certification Authorities > certificates > rightclick (All Tasks) > import" 

4. Import the root CA certificate you have which is now somewhere on your windows host system.
        
5. To quickly list out the whether you have deleted the root CA from your system you can the following PowerShell snippet on your host windows system:
        Get-ChildItem -Path Cert:\CurrentUser\Root | Where-Object { $_.Subject -match "CN=mkcert" }
EOF
        ;;
    (?)
        # usage
cat <<EOF
Usage:
./install-certificates.sh -m : Installs the mkcert dependency tool that we need to install root CA and create certificates. run this first.
./install-certificates.sh -l : Lists the directores where mkcert root CA lives.
./install-certificates.sh -i : Installs mkcert certificates root CA certs and puts certs into local trust store.
./install-certificates.sh -u : Removes mkcert root CA certificates.
./install-certificates.sh -c : Creates certificates to be used. You may alter the domain names in the example in the script.
./install-certificates.sh -w : Explains how to integrate with Windows hosts. This is useful if you did all the mkcert commands on WSL.
EOF
;;
esac
