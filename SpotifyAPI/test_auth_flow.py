import requests
import os
from urllib.parse import urlencode
import webbrowser
import base64
from io import BytesIO
from PIL import Image
from colorthief import ColorThief
import matplotlib.pyplot as plt


client_id = "1b563173e0f24796a66de09c8e177691"
client_secret = "6acc3b9c54dd496dbbf2ccef16976045"

def get_spotify_code(client_id=client_id, client_secret=client_secret):    
    url = 'https://accounts.spotify.com/authorize'
    params = {
        'client_id': client_id,
        'response_type': 'code',
        'scope': 'user-read-recently-played user-read-currently-playing',
        'redirect_uri': 'https://www.google.com'
    }
    url = f"{url}?{urlencode(params)}"
    print("Redirecting to Spotify for authorization...")
    webbrowser.open(url)
    code = input("Enter the code you received after authorization:")
    return code
    
    
def get_spotify_token(c, id=client_id, secret=client_secret):
    token_url = 'https://accounts.spotify.com/api/token'
    
    headers = {
        'Authorization': 'Basic ' + base64.b64encode(f"{id}:{secret}".encode()).decode('utf-8'),
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    data = {
        'grant_type': 'authorization_code',
        'code': c,
        'redirect_uri': 'https://www.google.com'
    }

    response = requests.post(token_url, headers=headers, data=data)
    

    if response.status_code == 200:
        response_data = response.json()
        with open('token.txt', 'w') as f:
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
        print(response['item']['album']['images'][0]['url'])
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

def refresh_token(refresh, id=client_id, secret=client_secret):
    url = 'https://accounts.spotify.com/api/token'
    data = {
        'grant_type': 'refresh_token',
        'refresh_token': refresh
    }    
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ' + base64.b64encode(f"{id}:{secret}".encode()).decode('utf-8'),
    }
    response = requests.post(url, headers=headers, data=data)
    

    if response.status_code == 200:
        response_data = response.json()
        with open('new_token.txt', 'w') as f:
            f.write(response_data['access_token'])
            #f.write('\n')
            #f.write(response_data['refresh_token'])
        return response_data['access_token']#, response_data['refresh_token']
    else:
        print(f"Error getting access token: {response_data}")
        return None, None

#code = get_spotify_code()

#token, refresh = get_spotify_token(code)

#print(f"Access Token: {token}")


with open('token.txt', 'r') as f:
    token = f.readline().strip()
    refresh = f.readline().strip()

token = refresh_token(refresh)
#print(f"Access Token: {token}")
u = get_current_album_art(token)

get_top_colors(u)