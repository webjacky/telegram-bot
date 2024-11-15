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

# Sistem güncellemesi ve bağımlılıkların yüklenmesi
echo "Updating system and installing required dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv screen nano

# Bot dizini ve sanal ortam kurulumu
echo "Setting up bot directory and virtual environment..."
mkdir -p ~/telegram-bot
cd ~/telegram-bot
python3 -m venv venv
source venv/bin/activate

# Python paketlerini yükleme
echo "Installing necessary Python packages..."
pip install telethon

# Botun Python dosyasını oluşturma
echo "Creating bot script..."
cat << 'EOF' > bot.py
import json
import re
from telethon import TelegramClient, events

# Config dosyasını yükle
with open('config.json', 'r') as config_file:
    config = json.load(config_file)

api_id = config['api_id']
api_hash = config['api_hash']
all_messages_groups = config['all_messages_groups']
filtered_groups = config['filtered_groups']
maestro_bot_id = config['maestro_bot_id']

sent_addresses_file = 'sent_addresses.json'

# Daha önce gönderilmiş adresleri yükle
try:
    with open(sent_addresses_file, 'r') as f:
        sent_addresses = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    sent_addresses = []

client = TelegramClient('bot_session', api_id, api_hash)

# Regex desenleri (örnek)
regex_patterns = {
    'solana': r'[1-9A-HJ-NP-Za-km-z]{32,44}',
    'ethereum': r'0x[a-fA-F0-9]{40}'
}

# Yeni mesajları işleme
@client.on(events.NewMessage)
async def handler(event):
    sender_id = event.sender_id
    chat_id = event.chat_id
    message = event.message.message

    # Tüm mesajları çeken gruplar
    if chat_id in all_messages_groups:
        await process_message(message, chat_id)

    # Filtreli gruplar
    elif str(chat_id) in filtered_groups:
        whitelist_user_ids = filtered_groups[str(chat_id)].get("whitelist_user_ids", [])
        if sender_id in whitelist_user_ids:
            await process_message(message, chat_id)

async def process_message(message, chat_id):
    found_addresses = set()  # Benzersiz adresler için
    for chain, pattern in regex_patterns.items():
        matches = re.findall(pattern, message)
        for address in matches:
            if address not in sent_addresses:
                print(f"Yeni {chain} adresi bulundu: {address}, grup ID: {chat_id}")
                await client.send_message(maestro_bot_id, f"Yeni {chain} adresi: {address}")
                sent_addresses.append(address)
                found_addresses.add(address)

    # Gönderilmiş adresleri kaydet
    if found_addresses:
        with open(sent_addresses_file, 'w') as f:
            json.dump(sent_addresses, f)

# Botu başlat
client.start()
print("Bot çalışıyor...")
client.run_until_disconnected()
EOF

# Config dosyasını oluşturma
echo "Creating configuration file template..."
cat << 'EOF' > config.json
{
    "api_id": "YOUR_API_ID",
    "api_hash": "YOUR_API_HASH",
    "all_messages_groups": [-1001234567890, -1009876543210],
    "filtered_groups": {
        "-1001122334455": {
            "whitelist_user_ids": [123456789, 987654321]
        }
    },
    "maestro_bot_id": "@maestro"
}
EOF

# Kullanıcıyı config dosyasını düzenlemeye yönlendirme
echo "Installation complete. Please update the 'config.json' file with your API details, group IDs, and filters."
nano config.json
