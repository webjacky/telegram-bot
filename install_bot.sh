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

# Update and install required packages
echo "Updating and installing required packages..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y python3 python3-venv screen git

# Create the bot working directory
mkdir -p ~/telegram_bot
cd ~/telegram_bot

# Set up the Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install required Python libraries
echo "Installing Python dependencies..."
pip install telethon

# Create the main Python bot file
echo "Creating bot.py..."
cat << 'EOF' > bot.py
import json
import asyncio
from telethon import TelegramClient, events

# Load config file
with open('config.json') as config_file:
    config = json.load(config_file)

api_id = config['api_id']
api_hash = config['api_hash']
maestro_bot_id = config['maestro_bot_id']
groups = config['groups']

client = TelegramClient('bot', api_id, api_hash)

@client.on(events.NewMessage)
async def handler(event):
    message = event.raw_text
    if any(keyword in message for keyword in ['Contract:', 'Address:']):
        address = message.split()[-1]
        # Prevent duplicate messages
        if not hasattr(client, 'processed_addresses'):
            client.processed_addresses = set()
        if address not in client.processed_addresses:
            client.processed_addresses.add(address)
            print(f"Group: {event.chat.title}, Contract: {address} - Successfully sent.")
            await client.send_message(maestro_bot_id, f"Contract Address: {address}")
        else:
            print(f"Group: {event.chat.title}, Contract: {address} - Duplicate address")

# Start the bot
async def main():
    await client.start()
    print("Bot is running...")
    await client.run_until_disconnected()

if __name__ == '__main__':
    asyncio.run(main())
EOF

# Create the config file
echo "Creating config.json..."
cat << 'EOF' > config.json
{
    "api_id": "Your_API_ID",
    "api_hash": "Your_API_Hash",
    "maestro_bot_id": "@YourMaestroBot",
    "groups": [-1001234567890, -1009876543210]
}
EOF

# Display installation instructions
echo -e "\nInstallation complete. Update the 'config.json' file with your API details and group IDs."
echo "To run the bot, use the following commands:"
echo -e "source ~/telegram_bot/venv/bin/activate\npython3 ~/telegram_bot/bot.py\n"
