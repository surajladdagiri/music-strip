import random
import hashlib
import base64
from urllib.parse import urlencode
import webbrowser
import requests
import matplotlib.pyplot as plt
import os
from colorthief import ColorThief
import pyperclip

id = "1b563173e0f24796a66de09c8e177691"

def generate_random_string(length=64):
    letters = list('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789')
    return ''.join(random.choice(letters) for i in range(length))

def sha256(input):
    data = input.encode('utf-8')
    return hashlib.sha256(data).digest()

def base64urlencode(inpu):
    encoded = base64.urlsafe_b64encode(inpu).decode('utf-8')
    return encoded.rstrip("=")


def generate_challenge():
    input = generate_random_string()
    with open('verifier.txt', 'w') as f:
        f.write(input)
    hash = sha256(input)
    base64_url = base64urlencode(hash)
    with open('challenge.txt', 'w') as f:
        f.write(base64_url)
    return input, base64_url


def get_spotify_code(challenge, id=id):    
    url = 'https://accounts.spotify.com/authorize'
    params = {
        'client_id': id,
        'response_type': 'code',
        'scope': 'user-read-recently-played user-read-currently-playing',
        'redirect_uri': 'https://www.google.com',
        'code_challenge_method': 'S256',
        'code_challenge': challenge
    }
    url = f"{url}?{urlencode(params)}"
    print("Redirecting to Spotify for authorization...")
    webbrowser.open(url)
    code = input("Enter the code you received after authorization:")
    return code



def get_spotify_token(code, verifier, id=id):
    token_url = 'https://accounts.spotify.com/api/token'
    
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    data = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': 'https://www.google.com',
        'client_id': id,
        'code_verifier': verifier
    }

    response = requests.post(token_url, headers=headers, data=data)
    

    if response.status_code == 200:
        response_data = response.json()
        with open('PKCE_token.txt', 'w') as f:
            f.write(response_data['access_token'])
            f.write('\n')
            f.write(response_data['refresh_token'])
        return response_data['access_token'], response_data['refresh_token']
    else:
        print(f"Error getting access token: {response_data}")
        return None, None


def get_current_album_art(token):
    url = 'https://api.spotify.com/v1/me/player/currently-playing'
    headers = {
        'Authorization': f'Bearer {token}'
    }
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        response = response.json()
        #print(response['item']['album']['images'][0]['url'])
        return response['item']['album']['images'][0]['url']
    else:
        print(f"Failed to get data: {response.status_code}")
        print(response)
        return None

def get_top_colors(url):

    img = requests.get(url).content
    with open('temp_image.jpg', 'wb') as f:
        f.write(img)
    palette = ColorThief('temp_image.jpg').get_palette(color_count=5)
    os.remove('temp_image.jpg') 
    plt.figure(figsize=(6, 2))
    plt.imshow([palette])
    plt.axis('off')
    plt.show()
    return palette

def refresh_token(refresh, id=id):
    url = 'https://accounts.spotify.com/api/token'
    data = {
        'grant_type': 'refresh_token',
        'refresh_token': refresh,
        'client_id': id
    }
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    response = requests.post(url, data=data, headers=headers)
    if response.status_code == 200:
        response_data = response.json()
        with open('new_token_PKCE.txt', 'w') as f:
            f.write(response_data['access_token'])
            f.write('\n')
            f.write(response_data['refresh_token'])
            print(response_data)
        return response_data['access_token'], response_data['refresh_token']
    else:
        print(f"Error getting access token: {response_data}")
        return None, None
    
"""
verifier, challenge = generate_challenge()

code = get_spotify_code(challenge)
access, refresh = get_spotify_token(code, verifier)
#with open('new_token_PKCE.txt', 'r') as f:
#    access = f.readline().strip()
#    refresh = f.readline().strip()

#access, refresh = refresh_token(refresh)
pyperclip.copy(refresh)
u = get_current_album_art(access)
get_top_colors(u)

"""