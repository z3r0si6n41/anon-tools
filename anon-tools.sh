#!/bin/bash

echo "z3r0's Simple Anonymity Tool Installer"
echo "This tool will install tor, I2P, dnscrypt-proxy, and proxychains if not found."
echo "It is highly recommended that you read the documentation for these tools"
echo
echo "Testing for Tor"
if ! command -v tor &> /dev/null
then
	echo "Installing Tor..."
	sudo apt install -y tor
fi
echo "Tor installation complete."
echo
echo

echo "Testing for I2P"
if ! command -v i2prouter &> /dev/null
then
	echo "Installing I2P..."
	sudo apt install -y i2p
fi
echo "I2P installation complete."
echo
echo

echo "Testing for dnscrypt-proxy"
if sudo dnscrypt-proxy -version | grep -q 'not found';
then
	echo "Installing dnscrypt."
	sudo apt purge dnscrypt-proxy
	sudo apt install dnscrypt-proxy
	sudo cp /etc/dnscrypt-proxy/example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
	sudo apt remove resolvconf
	sudo cp /etc/resolv.conf /etc/resolv.conf.backup
	sudo rm -f /etc/resolv.conf
	sudo touch /etc/resolv.conf
	sudo echo -e "nameserver 127.0.0.1\noptions edns0" >> /etc/resolv.conf
	sudo dnscrypt-proxy -service install
fi
echo "dnscrypt-proxy installation complete."
echo
echo

echo "Testing for proxychains"
if ! command -v proxychains4 &> /dev/null
then
	echo "Installing proxychains..."
	sudo apt install -y proxychains4
fi
echo "proxychains installation complete. However, you must perform manual installation setup steps:"
echo "1) Run 'nano /etc/proxychains.conf'"
echo "2) Make sure there is a comment character (#) before strict_chain and random_chain. Make sure there is NOT a comment before dynamic_chain."
echo "3) Make sure there is NOT a comment before proxy_dns. Optionally, you might want to disable all of the extra output by making sure there is not a comment before quiet_mode."
echo "4) At the end of the file, after 'socks4 127.0.0.1 9050' add a new line with 'socks5 127.0.0.1 9050'."
echo "5) Save and close the file."
echo

touch ~/anon-tools
echo "#!/bin/bash" >> ~/anon-tools
echo "# z3r0's Simple Anonymity Tools" >> ~/anon-tools
echo "sudo killall tor" >> ~/anon-tools
echo "sudo service tor start" >> ~/anon-tools
echo "i2prouter start" >> ~/anon-tools
echo "sudo dnscrypt-proxy -service start" >> ~/anon-tools

echo "Would you like to install a VPN? (Manual registration required) [y/n]: "
read -n 1 installVPN
if [[ "${installVPN,,}" == "y" ]]; then
	declare -a VPNS=('NordVPN' 'ExpressVPN' 'ProtonVPN')
	echo "Install which VPN?"
	for val in ${VPNS[@]}; do
		str="${k}. ${VPNS[$k-1]}"
		echo "${str}"
	done
	echo "[1-${#VPNS[@]}]: "
	read -n 1 vpnChoice
	
	echo "echo 'Starting VPN...'" >> ~/anon-tools

	if [[ "${vpnChoice}" == 1 ]]; then
		echo "Installing NordVPN..."
		wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb
		sudo dpkg -i ./nordvpn-release_1.0.0_all.deb
		sudo apt update
		sudo apt -y install nordvpn
		rm nordvpn*.deb
		nordvpn login
		echo "nordvpn connect" >> ~/anon-tools
	fi
	
	if [[ "${vpnChoice}" == 2 ]]; then
		echo "Installing ExpressVPN..."
		sudo apt install -y openvpn resolvconf
		echo "Enter filepath of your ovpn config file: "
		read configPath
		echo "sudo openvpn --config ${configPath} --script-security 2 --up /etc/openvpn/update-resolv-conf --down /etc/openvpn/update-resolv-conf" >> ~/anon-tools
	fi

	if [[ "${vpnChoice}" == 3 ]]; then
		sudo apt install -y openvpn dialog python3-pip python3-setuptools
		sudo pip3 install protonvpn-cli
		sudo protonvpn init
		echo "sudo protonvpn c" >> ~/anon-tools
	fi
fi

echo "echo 'Connected and ready. You may now do your work in anonymity.'" >> ~/anon-tools
sudo chmod 777 ~/anon-tools

echo "You may now run '~/anon-tools' whenever you need to be anonymous."
exit 0
