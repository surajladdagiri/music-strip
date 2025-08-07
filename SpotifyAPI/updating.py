from test_PKCE_flow import refresh_token, get_current_album_art
import time
import matplotlib.pyplot as plt
import os
from colorthief import ColorThief
import requests
from serial import Serial



def retrieve_old_tokens(path='new_token_PKCE.txt'):

    with open(path, 'r') as f:
        access = f.readline().strip()
        refresh = f.readline().strip()
    return refresh

def get_top_colors(url):
    if not url:
        return
    img = requests.get(url).content
    with open('temp_image.jpg', 'wb') as f:
        f.write(img)
    palette = ColorThief('temp_image.jpg').get_palette(color_count=3)
    os.remove('temp_image.jpg') 
    return ','.join([f'R{r}G{g}B{b}' for r, g, b in palette])

def update(re, delay=2):
    access, refresh = refresh_token(re)
    curr = get_current_album_art(access)
    get_top_colors(curr)
    while True:
        time.sleep(delay)
        new = get_current_album_art(access)
        if new == curr:
            continue
        curr = new
        colors = get_top_colors(curr)
        ser.write((colors + '\n').encode())

SERIAL_PORT = '/dev/tty.usbmodem2101' 
BAUD_RATE = 115200

ser = Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
time.sleep(2)

re = retrieve_old_tokens()
update(re)