#!/bin/bash

# Update package list and install necessary packages
apt update && apt upgrade -y
apt install python3 python3-pip git -y

# Install required Python packages
pip3 install telethon

# Create a directory for the bot
mkdir -p ~/telegram_bot
cd ~/telegram_bot

# Download the bot script and config file
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

# File to track sent addresses
sent_addresses_file = 'sent_addresses.json'

# Load sent addresses
try:
    with open(sent_addresses_file, 'r') as f:
        sent_addresses = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    sent_addresses = []

client = TelegramClient('bot_session', api_id, api_hash)

# Regex patterns for different blockchains
solana_contract_regex = r'[1-9A-HJ-NP-Za-km-z]{32,44}'
ethereum_contract_regex = r'0x[a-fA-F0-9]{40}'
avax_contract_regex = r'0x[a-fA-F0-9]{40}'
bsc_contract_regex = r'0x[a-fA-F0-9]{40}'
arbitrum_contract_regex = r'0x[a-fA-F0-9]{40}'
base_chain_contract_regex = r'0x[a-fA-F0-9]{40}'
tron_chain_contract_regex = r'[T][a-zA-Z0-9]{33}'

@client.on(events.NewMessage(chats=groups))
async def handler(event):
    message = event.message.message
    sender_id = event.chat_id
    contract_addresses = re.findall(
        f'{solana_contract_regex}|{ethereum_contract_regex}|{avax_contract_regex}|{bsc_contract_regex}|{arbitrum_contract_regex}|{base_chain_contract_regex}|{tron_chain_contract_regex}',
        message
    )

    if contract_addresses:
        new_addresses = []
        for address in contract_addresses:
            if address not in sent_addresses:
                print(f"New contract address found: {address}, group ID: {sender_id}")
                await client.send_message(maestro_bot_id, f'New contract address: {address}')
                print(f"Address successfully sent to {maestro_bot_id}: {address}")
                sent_addresses.append(address)
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
EOF

cat << 'EOF' > config.json
{
    "api_id": "YOUR_API_ID",
    "api_hash": "YOUR_API_HASH",
    "groups": [-1001234567890],
    "maestro_bot_id": "@your_maestro_bot"
}
EOF

# Give execution permission to the bot script
chmod +x bot.py

# Open the config file for editing
nano config.json
