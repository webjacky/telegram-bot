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

# Update and install dependencies
echo "Updating system and installing required dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv screen nano

# Set up the bot directory and virtual environment
echo "Setting up bot directory and virtual environment..."
mkdir -p ~/telegram_bot
cd ~/telegram_bot
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

# Define blockchain contract address patterns
contract_patterns = {
    'solana': r'[1-9A-HJ-NP-Za-km-z]{32,44}',
    'ethereum': r'0x[a-fA-F0-9]{40}',
    'avalanche': r'0x[a-fA-F0-9]{40}',
    'binance_smart_chain': r'0x[a-fA-F0-9]{40}',
    'arbitrum': r'0x[a-fA-F0-9]{40}',
    'base_chain': r'0x[a-fA-F0-9]{40}',
    'tron': r'T[A-Za-z1-9]{33}'
}

# Handle new messages
@client.on(events.NewMessage(chats=groups))
async def handler(event):
    message = event.message.message
    sender_id = event.chat_id

    for chain, pattern in contract_patterns.items():
        contract_addresses = re.findall(pattern, message)
        if contract_addresses:
            new_addresses = []
            for address in contract_addresses:
                if address not in sent_addresses:
                    print(f"New {chain} contract address found: {address}, group ID: {sender_id}")
                    await client.send_message(maestro_bot_id, f'New {chain} contract address: {address}')
                    print(f"Successfully sent to {maestro_bot_id}: {address}")
                    sent_addresses.append(address)
                    new_addresses.append(address)
                else:
                    print(f"Address already sent: {address}")

            # Save updated sent addresses list to file only if there are new addresses
            if new_addresses:
                try:
                    with open(sent_addresses_file, 'w') as f:
                        json.dump(sent_addresses, f)
                except Exception as e:
                    print(f"Error saving sent addresses: {e}")

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
    "groups": [123456789, 987654321],
    "maestro_bot_id": "@maestro"
}
EOF

# Notify user to update config.json
echo "Installation complete. Please update the 'config.json' file with your API details and group IDs."
echo "Once updated, you can run the bot using the command:"
echo "screen -dmS telegram_bot python3 bot.py"
echo "To resume the screen session, use: screen -r telegram_bot"
