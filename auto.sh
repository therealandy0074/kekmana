#!/data/data/com.termux/files/usr/bin/bash

#check for autoboot
if [ "$(su -c '[ -f /etc/init/autoboot.rc ] && echo exists')" != "exists" ]; then
  echo "Creating autoboot.rc file..."

  # Switch to su mode
  su -c '
    cd /etc/init || exit 1
    echo -e "oncharger\nsetprop sys.powerctl reboot" > autoboot.rc
    chmod 644 autoboot.rc
  '

  echo "autoboot.rc created and permissions set."
else
  echo "autoboot.rc already exists. Skipping creation."
fi

# Update and install required packages
echo "Updating and installing required packages..."
pkg update && pkg upgrade -y
pkg install libjansson wget nano -y

# Enable auto-run for Termux on boot
echo "Setting up Termux boot support..."
mkdir -p ~/.termux/boot
echo "allow-external-apps=true" > ~/.termux/termux.properties

# Create ccminer directory and download required files
echo "Downloading ccminer files..."
mkdir -p ~/ccminer && cd ~/ccminer
wget -q https://raw.githubusercontent.com/Burhan7610/autorun-ccminer-termux/main/ccminer
curl -o config.json https://raw.githubusercontent.com/therealandy0074/kekmana/refs/heads/main/config.json
wget -q https://raw.githubusercontent.com/Burhan7610/autorun-ccminer-termux/main/verus

# Set executable permissions
echo "Setting executable permissions..."
chmod +x ccminer verus
cp ./verus ../../usr/bin/verus

# Create start-verus script for Termux boot
echo "Creating start-verus boot script..."
cat > ~/.termux/boot/start-verus <<EOF
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
am startservice --user 0 -n com.termux/com.termux.app.RunCommandService \\
-a com.termux.RUN_COMMAND \\
--es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/verus' \\
--esa com.termux.RUN_COMMAND_ARGUMENTS '-n,5' \\
--es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \\
--ez com.termux.RUN_COMMAND_BACKGROUND 'false' \\
--es com.termux.RUN_COMMAND_SESSION_ACTION '1'
EOF

chmod +x ~/.termux/boot/start-verus

echo "Installation complete! Please restart Termux to test the auto-run feature."
