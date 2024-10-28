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
import os
import json
import asyncio
from telethon import TelegramClient

# Path to config.json file
config_path = os.path.expanduser('~/telegram_bot/config.json')

# Load config.json file
with open(config_path) as config_file:
    config = json.load(config_file)

# Start the Telethon client
client = TelegramClient('session_name', config['api_id'], config['api_hash'])

async def main():
    await client.start()
    print("Bot started. You can perform your desired actions.")

try:
    asyncio.run(main())
except KeyboardInterrupt:
    print("Bot stopped.")
EOL

# Completion message
echo "Installation complete. Update the 'config.json' file with your API details and group IDs."
echo "To run the bot, use the following commands:"
echo "source ~/telegram_bot/venv/bin/activate"
echo "python3 ~/telegram_bot/bot.py"
