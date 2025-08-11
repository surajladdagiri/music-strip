from test_PKCE_flow import refresh_token, get_current_album_art
import time
import matplotlib.pyplot as plt
import os
from serial import Serial



SERIAL_PORT = '/dev/tty.usbmodem2101' 
BAUD_RATE = 115200

ser = Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
time.sleep(2)



while True:
    data = ser.readline().decode('utf-8').strip()
    if data:
        if data.startswith('R:'):
            print(data)
        """
        plt.close('all')
        print(f"Received data: {data}")
        rgb_values = data.split(':')
        palette = []
        for i, rgb in enumerate(rgb_values):
            r = int(rgb[1:rgb.index('G')])
            g = int(rgb[rgb.index('G')+1:rgb.index('B')])
            b = int(rgb[rgb.index('B')+1:])
            palette.append((r, g, b))
        plt.figure(figsize=(6, 2))
        plt.imshow([palette])
        plt.axis('off')
        plt.show()
"""