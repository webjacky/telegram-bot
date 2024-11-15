#!/bin/bash

clear
echo -e "\e[32m"
echo "██╗    ██╗███████╗██████╗      ██╗ █████╗  ██████╗██╗  ██╗";
echo "██║    ██║██╔════╝██╔══██╗    ███║██╔══██╗██╔════╝██║ ██╔╝";
echo "██║ █╗ ██║█████╗  ██║  ██║    ╚██║███████║██║     █████╔╝ ";
echo "██║███╗██║██╔══╝  ██║  ██║     ██║██╔══██║██║     ██╔═██╗ ";
echo "╚███╔███╔╝███████╗██████╔╝     ██║██║  ██║╚██████╗██║  ██╗";
echo " ╚══╝╚══╝ ╚══════╝╚═════╝      ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝";
sleep 3

clear
echo -e "\e[32mStarting Web Jack Bot Installer...\e[0m"
sleep 2

# System update and installing dependencies
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
import re
from telethon import TelegramClient, events

# Load configuration
with open('config.json', 'r') as config_file:
    config = json.load(config_file)

api_id = config['api_id']
api_hash = config['api_hash']
groups = config['groups']
maestro_bot_id = config['maestro_bot_id']

sent_addresses_file = 'sent_addresses.json'

# Load previously sent addresses, if any
try:
    with open(sent_addresses_file, 'r') as f:
        sent_addresses = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    sent_addresses = []

client = TelegramClient('bot_session', api_id, api_hash)

# Define regex patterns for contract addresses across various chains
regex_patterns = {
    'solana': r'[1-9A-HJ-NP-Za-km-z]{32,44}',
    'ethereum': r'0x[a-fA-F0-9]{40}',
    'bsc': r'0x[a-fA-F0-9]{40}',
    'avalanche': r'0x[a-fA-F0-9]{40}',
    'arbitrum': r'0x[a-fA-F0-9]{40}',
    'base': r'0x[a-fA-F0-9]{40}',
    'tron': r'T[a-zA-Z0-9]{33}'
}

# Handle new messages
@client.on(events.NewMessage(chats=list(groups.keys())))
async def handler(event):
    message = event.message.message
    sender_id = event.chat_id
    group_settings = groups.get(str(sender_id), {})
    found_addresses = set()  # Use a set to store unique addresses only

    # Whitelist user filter
    if 'whitelist_user_ids' in group_settings and group_settings['whitelist_user_ids']:
        if event.sender_id not in group_settings['whitelist_user_ids']:
            return

    # Blacklist and Whitelist keyword filters
    if 'blacklist_keywords' in group_settings:
        if any(black in message for black in group_settings['blacklist_keywords']):
            return
    if 'whitelist_keywords' in group_settings and group_settings['whitelist_keywords']:
        if not any(white in message for white in group_settings['whitelist_keywords']):
            return

    for chain, pattern in regex_patterns.items():
        contract_addresses = re.findall(pattern, message)
        unique_addresses = set(contract_addresses)  # Filter duplicates

        for address in unique_addresses:
            if address not in sent_addresses:
                print(f"New {chain} contract address found: {address}, group ID: {sender_id}")
                await client.send_message(maestro_bot_id, f'New {chain} contract address: {address}')
                print(f"Successfully sent to {maestro_bot_id}: {address}")
                sent_addresses.append(address)
                found_addresses.add(address)
            else:
                print(f"Address already sent: {address}")

    # Save the updated list of sent addresses
    if found_addresses:
        with open(sent_addresses_file, 'w') as f:
            json.dump(sent_addresses, f)

# Start the bot
client.start()
print("Bot is running...")
client.run_until_disconnected()
EOF

# Create configuration file template
echo "Creating configuration file template..."
cat << 'EOF' > config.json
{
    "api_id": "YOUR_API_ID",
    "api_hash": "YOUR_API_HASH",
    "groups": {
        "-100123456789": {
            "whitelist_user_ids": [],
            "blacklist_keywords": [],
            "whitelist_keywords": []
        },
        "-100987654321": {
            "blacklist_keywords": ["banword"],
            "whitelist_keywords": []
        }
    },
    "maestro_bot_id": "@maestro"
}
EOF

# Notify user to update config.json and open it in nano
echo "Installation complete. Please update the 'config.json' file with your API details and group settings."
nano config.json
