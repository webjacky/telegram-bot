#!/bin/bash

# Install necessary packages
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
    "groups": [-1001234567890, -1009876543210],  # Replace with your group IDs
    "maestro_bot_id": "@yourmaestro_bot"
}
EOL

# Create the bot.py file
cat <<EOL > bot.py
import json
import re
from telethon import TelegramClient, events

with open('config.json', 'r') as config_file:
    config = json.load(config_file)

api_id = config['api_id']
api_hash = config['api_hash']
groups = config['groups']
maestro_bot_id = config['maestro_bot_id']

sent_addresses_file = 'sent_addresses.json'

try:
    with open(sent_addresses_file, 'r') as f:
        sent_addresses = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    sent_addresses = []

client = TelegramClient('bot_session', api_id, api_hash)

# Regex patterns for contract addresses
solana_contract_regex = r'[1-9A-HJ-NP-Za-km-z]{32,44}'  # Solana
ethereum_contract_regex = r'0x[a-fA-F0-9]{40}'  # Ethereum
bsc_contract_regex = r'0x[a-fA-F0-9]{40}'  # Binance Smart Chain
avalanche_contract_regex = r'0x[a-fA-F0-9]{40}'  # Avalanche
arbitrum_contract_regex = r'0x[a-fA-F0-9]{40}'  # Arbitrum
tron_contract_regex = r'T[a-zA-Z0-9]{33}'  # Tron
base_chain_contract_regex = r'0x[a-fA-F0-9]{40}'  # Base Chain

@client.on(events.NewMessage(chats=groups))
async def handler(event):
    message = event.message.message
    sender_id = event.chat_id
    contract_addresses = (
        re.findall(solana_contract_regex, message) + 
        re.findall(ethereum_contract_regex, message) + 
        re.findall(bsc_contract_regex, message) + 
        re.findall(avalanche_contract_regex, message) + 
        re.findall(arbitrum_contract_regex, message) + 
        re.findall(tron_contract_regex, message) +
        re.findall(base_chain_contract_regex, message)  # Base Chain included
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

client.start()
print("Bot is running...")
client.run_until_disconnected()
EOL

# Give execute permissions to the bot.py
chmod +x bot.py

# Run the bot in screen
screen -dm bash -c 'source venv/bin/activate && python3 bot.py'

echo "Installation complete. Your bot is running in a detached screen session."
echo "You can update the 'config.json' file with your API details and group IDs."
