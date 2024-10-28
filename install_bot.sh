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

#!/bin/bash

# Install necessary libraries
apt-get update
apt-get install -y python3 python3-venv git

# Create the working directory
mkdir -p ~/telegram_bot
cd ~/telegram_bot

# Create a virtual environment
python3 -m venv venv
source venv/bin/activate

# Install required Python libraries
pip install telethon

# Create config.json file
cat <<EOL > config.json
{
    "api_id": "YOUR_API_ID",
    "api_hash": "YOUR_API_HASH",
    "groups": [],
    "maestro_bot_id": "@maestro"
}
EOL

# Create bot.py file
cat <<EOL > bot.py
import json
import re
from telethon import TelegramClient, events
import os

# Load configuration from 'config.json' in the same directory as the script
config_path = os.path.join(os.path.dirname(__file__), 'config.json')
with open(config_path, 'r') as config_file:
    config = json.load(config_file)

api_id = config['api_id']
api_hash = config['api_hash']
groups = config['groups']
maestro_bot_id = config['maestro_bot_id']

# File to store sent addresses
sent_addresses_file = os.path.join(os.path.dirname(__file__), 'sent_addresses.json')

# Load previously sent addresses, if any
try:
    with open(sent_addresses_file, 'r') as f:
        sent_addresses = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    sent_addresses = []

client = TelegramClient('bot_session', api_id, api_hash)

# Solana contract address regex pattern
solana_contract_regex = r'[1-9A-HJ-NP-Za-km-z]{32,44}'

@client.on(events.NewMessage(chats=groups))
async def handler(event):
    message = event.message.message
    sender_id = event.chat_id  # ID of the group or channel where the message came from
    contract_addresses = re.findall(solana_contract_regex, message)  # Find Solana contract addresses

    if contract_addresses:
        new_addresses = []
        for address in contract_addresses:
            if address not in sent_addresses:
                # New address found, sending to Maestro Bot
                print(f"New contract address found: {address}, group ID: {sender_id}")
                await client.send_message(maestro_bot_id, f'New Solana contract address: {address}')
                print(f"Address successfully sent to {maestro_bot_id}: {address}")
                sent_addresses.append(address)  # Add the new address to the list
                new_addresses.append(address)
            else:
                print(f"Address already sent: {address}")
        if new_addresses:
            with open(sent_addresses_file, 'w') as f:
                json.dump(sent_addresses, f)

# Start the bot
client.start()
print("Bot is running...")
client.run_until_disconnected()


EOL

# Completion message
echo "Installation complete. Update the 'config.json' file with your API details and group IDs."
echo "To run the bot, use the following commands:"
echo "source ~/telegram_bot/venv/bin/activate"
echo "python3 ~/telegram_bot/bot.py"
