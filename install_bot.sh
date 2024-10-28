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
import asyncio
from telethon import TelegramClient, events

# Load configuration
with open('config.json') as config_file:
    config = json.load(config_file)

api_id = config['api_id']
api_hash = config['api_hash']
groups = config['groups']

# Create a set to keep track of sent contract addresses
sent_contracts = set()

# Create Telegram client
client = TelegramClient('bot', api_id, api_hash)

@client.on(events.NewMessage(chats=groups)
def handler(event):
    message = event.message.message
    if 'Contract' in message:  # Check if the message contains a contract address
        contract_address = message.split('Contract: ')[-1].strip()
        
        # Check if the contract address has already been sent
        if contract_address in sent_contracts:
            print(f"Already sent: {contract_address}")
            return
        
        # Log the received contract address with group name
        group_name = event.chat.title if event.chat.title else event.chat.username
        print(f"Received in {group_name}: {contract_address}")

        # Send the contract address to the desired channel/group
        await client.send_message('your_destination_group', f"Contract Address: {contract_address}")
        
        # Add the contract address to the sent list
        sent_contracts.add(contract_address)
        print(f"Contract {contract_address} sent successfully!")

async def main():
    print("Bot is running...")
    await client.start()
    await client.run_until_disconnected()

if __name__ == "__main__":
    asyncio.run(main())

EOL

# Completion message
echo "Installation complete. Update the 'config.json' file with your API details and group IDs."
echo "To run the bot, use the following commands:"
echo "source ~/telegram_bot/venv/bin/activate"
echo "python3 ~/telegram_bot/bot.py"
