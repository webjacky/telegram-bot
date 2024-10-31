#!/bin/bash

# Clear the screen
clear

# Define the banner text
banner_text="██╗    ██╗███████╗██████╗      ██╗ █████╗  ██████╗██╗  ██╗
██║    ██║██╔════╝██╔══██╗    ███║██╔══██╗██╔════╝██║ ██╔╝
██║ █╗ ██║█████╗  ██║  ██║    ╚██║███████║██║     █████╔╝ 
██║███╗██║██╔══╝  ██║  ██║     ██║██╔══██║██║     ██╔═██╗ 
╚███╔███╔╝███████╗██████╔╝     ██║██║  ██║╚██████╗██║  ██╗
 ╚══╝╚══╝ ╚══════╝╚═════╝      ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝"

# Print the banner with a faster animation
for (( i=0; i<${#banner_text}; i++ )); do
    echo -n "${banner_text:i:1}"
    sleep 0.01  # Speed up the animation
done
echo # New line after the banner
sleep 1

# Clear the screen
clear
echo -e "\e[32mStarting Web Jack Bot Installer...\e[0m"
sleep 1

# Update and install dependencies
echo "Updating system and installing required dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv screen nano

# Set up the bot directory and virtual environment
echo "Setting up bot directory and virtual environment..."
mkdir -p ~/telegram-bot
cd ~/telegram-bot
python3 -m venv venv
source venv/bin/activate

# Install necessary Python packages
echo "Installing necessary Python packages..."
pip install telethon

# Create the bot's Python script
echo "Creating bot script..."
cat << 'EOF' > bot.py
import json
from telethon import TelegramClient, events

# Load configuration
with open('config.json', 'r') as config_file:
    config = json.load(config_file)

api_id = config['api_id']
api_hash = config['api_hash']
client = TelegramClient('session_name', api_id, api_hash)

@client.on(events.NewMessage)
async def handler(event):
    # Handle new message event
    print(event.message)

client.start()
client.run_until_disconnected()
EOF

# Create configuration file template
echo "Creating configuration file template..."
cat << 'EOF' > config.json
{
    "api_id": "YOUR_API_ID",
    "api_hash": "YOUR_API_HASH",
    "groups": []
}
EOF

# Change permissions
chmod +x bot.py

# Show completion message
echo "Installation complete. Please update the 'config.json' file with your API details."
echo "Now you are in the bot directory. You can run the bot using the command:"
echo "screen -dmS telegram_bot python3 bot.py"

# Move to bot directory
cd ~/telegram-bot
