#!/bin/bash

# Update and install required packages
apt update && apt install -y python3 python3-pip git

# Create a directory for the bot
mkdir -p ~/telegram_bot
cd ~/telegram_bot

# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install required Python packages
pip install telethon

# Create config.json file
cat <<EOL > config.json
{
    "api_id": "YOUR_API_ID",
    "api_hash": "YOUR_API_HASH",
    "groups": [-1001234567890],
    "maestro_bot_id": "@your_bot_id"
}
EOL

# Create bot.py file
cat <<EOL > bot.py
import json
import re
from telethon import TelegramClient, events

# Load configuration from config.json
with open('config.json', 'r') as config_file:
    config = json.load(config_file)

api_id = config['api_id']
api_hash = config['api_hash']
groups = config['groups']
maestro_bot_id = config['maestro_bot_id']

# File to store sent addresses
sent_addresses_file = 'sent_addresses.json'

# Load previously sent addresses
try:
    with open(sent_addresses_file, 'r') as f:
        sent_addresses = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    sent_addresses = []

client = TelegramClient('bot_session', api_id, api_hash)

# Regular expressions for different blockchain contract addresses
solana_contract_regex = r'[1-9A-HJ-NP-Za-km-z]{32,44}'  # Solana
ethereum_contract_regex = r'0x[a-fA-F0-9]{40}'          # Ethereum
avalanche_contract_regex = r'0x[a-fA-F0-9]{40}'          # Avalanche
bsc_contract_regex = r'0x[a-fA-F0-9]{40}'                # Binance Smart Chain
arbitrum_contract_regex = r'0x[a-fA-F0-9]{40}'           # Arbitrum
base_chain_contract_regex = r'0x[a-fA-F0-9]{40}'         # Base Chain
tron_contract_regex = r'T[a-zA-Z0-9]{33}'                # Tron Chain

@client.on(events.NewMessage(chats=groups))
async def handler(event):
    message = event.message.message
    sender_id = event.chat_id  # Message sender group or channel ID
    contract_addresses = []

    # Check for contract addresses in the message for each blockchain
    contract_addresses.extend(re.findall(solana_contract_regex, message))
    contract_addresses.extend(re.findall(ethereum_contract_regex, message))
    contract_addresses.extend(re.findall(avalanche_contract_regex, message))
    contract_addresses.extend(re.findall(bsc_contract_regex, message))
    contract_addresses.extend(re.findall(arbitrum_contract_regex, message))
    contract_addresses.extend(re.findall(base_chain_contract_regex, message))
    contract_addresses.extend(re.findall(tron_contract_regex, message))

    # Process found contract addresses
    if contract_addresses:
        new_addresses = []
        for address in contract_addresses:
            if address not in sent_addresses:
                print(f"New contract address found: {address}, group ID: {sender_id}")
                await client.send_message(maestro_bot_id, f'New contract address: {address}')
                print(f"Address successfully sent to {maestro_bot_id}: {address}")
                sent_addresses.append(address)  # Add new address to the list
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

# Provide execution permissions
chmod +x bot.py

# Open the config.json file in nano editor
nano config.json

echo "Bot has been installed. You can now edit the config.json file."
echo "To start the bot, run the following command:"
echo "screen -dmS telegram_bot python3 bot.py"
