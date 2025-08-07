#include <Arduino.h>
#include <Preferences.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <FastLED.h>

#define LED_PIN     5
#define NUM_LEDS    300
#define CHIPSET     WS2812B
#define COLOR_ORDER GRB
#define SERVICE_UUID "54df84fc-7f55-4867-bb29-617f9d2a7925"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

Preferences preferences;
int speed = 60;
int brightness = 100;
int steps = 100;
enum Mode { OFF, MANUAL, SPOTIFY };
enum ManualAnim { MANUAL_STATIC_SINGLE, MANUAL_FADE, MANUAL_SNAKE, MANUAL_SWAP };
enum SpotifyAnim { SPOTIFY_SNAKE, SPOTIFY_SWAP, SPOTIFY_FADE };
Mode mode = OFF;
ManualAnim manualAnim = MANUAL_STATIC_SINGLE;
SpotifyAnim spotifyAnim = SPOTIFY_SNAKE;
CRGB leds[NUM_LEDS];
CRGB rainbow[] = {
  CRGB::Red,
  CRGB::Orange,
  CRGB::Yellow,
  CRGB::Green,
  CRGB::Blue,
  CRGB::Indigo,
  CRGB::Violet
};
CRGB spotify_palette[]= {
  CRGB::Red,
  CRGB::Orange,
  CRGB::Yellow,
  CRGB::Green,
  CRGB::Blue,
  CRGB::Indigo,
  CRGB::Violet
};
int spotify_size = 7;
BLECharacteristic *pCharacteristic;
CRGB curr_color = CRGB::Blue;
bool killed = false;
bool needToKill = true;
BLEAdvertising *pAdvertising;

class CommandCallback : public BLECharacteristicCallbacks {
  void savePreferences() {
    preferences.putInt("speed", speed);
    preferences.putInt("brightness", brightness);
    preferences.putInt("mode", mode);
    preferences.putInt("manualAnim", manualAnim);
    preferences.putInt("spotifyAnim", spotifyAnim);
    preferences.putInt("steps", steps);
  }

  void onConnect(BLEServer* pServer) {
    pAdvertising->start();
  }

  void onDisconnect(BLEServer* pServer) {
    pAdvertising->start();
  }

  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string rxValue = pCharacteristic->getValue();
    if (rxValue.length() > 0) {
      String command = String(rxValue.c_str());

      int colon = command.indexOf(':');
      if (colon == -1) {
        Serial.println("Invalid BLE command format. Use key:value");
        return;
      }

      String key = command.substring(0, colon);
      key.trim();
      String value = command.substring(colon + 1);
      value.trim();

      if (key == "speed") {
        speed = value.toInt();
        needToKill = false;
      } else if (key == "brightness") {
        needToKill = false;
        brightness = value.toInt();
        FastLED.setBrightness(brightness);
      } else if (key == "steps") {
        steps = value.toInt();
      } else if (key == "mode") {
        if (value == "off") mode = OFF;
        else if (value == "manual") mode = MANUAL;
        else if (value == "spotify") mode = SPOTIFY;
        else Serial.println("Invalid mode.");
      } else if (key == "manual") {
        if (value == "static_single") manualAnim = MANUAL_STATIC_SINGLE;
        else if (value == "fade") manualAnim = MANUAL_FADE;
        else if (value == "snake") manualAnim = MANUAL_SNAKE;
        else if (value == "swap") manualAnim = MANUAL_SWAP;
        else Serial.println("Invalid manual animation.");
      } else if (key == "spotify") {
        if (value == "fade") spotifyAnim = SPOTIFY_FADE;
        else if (value == "snake") spotifyAnim = SPOTIFY_SNAKE;
        else if (value == "swap") spotifyAnim = SPOTIFY_SWAP;
        else Serial.println("Invalid spotify animation.");
      }
      if (needToKill){
        killed = true;
      }else{
        needToKill = true;
      }
      
      savePreferences();
    }
  }
};





void retrievePreferences() {
  preferences.begin("Music Strip", false); 
  speed = preferences.getInt("speed", 60);
  brightness = preferences.getInt("brightness", 100);
  steps = preferences.getInt("steps", 100);
  mode = static_cast<Mode>(preferences.getInt("mode", OFF));
  manualAnim = static_cast<ManualAnim>(preferences.getInt("manualAnim", MANUAL_STATIC_SINGLE));
  spotifyAnim = static_cast<SpotifyAnim>(preferences.getInt("spotifyAnim", SPOTIFY_SNAKE));
}

void savePreferences() {
  preferences.putInt("speed", speed);
  preferences.putInt("brightness", brightness);
  preferences.putInt("mode", mode);
  preferences.putInt("manualAnim", manualAnim);
  preferences.putInt("spotifyAnim", spotifyAnim);
  preferences.putInt("steps", steps);
}

void snake(CRGB palette[], int size) {
  int lengthOfSegment = NUM_LEDS/size;
  int extend = 0;
  for (int offset = 0; offset < NUM_LEDS; offset++){
    for (int i = 0; i < size; i++){
      for (int j = 0; j < lengthOfSegment; j++){
        int ledIndex = (offset + (i * lengthOfSegment) + j) % NUM_LEDS;
        leds[ledIndex] = palette[i];
        if (killed) {
          killed = false;
          return;
        }
      }
    }
    FastLED.show();
    FastLED.delay(1000 / speed);
  }
}

void static_single(CRGB color){
  fill_solid(leds, NUM_LEDS, color);
  FastLED.show();
}

void swap(CRGB palette[], int size) {
  if (size < 2) return;

  for (int i = 0; i < size; i++){
    fill_solid(leds, NUM_LEDS, palette[i]);
    FastLED.show();
    FastLED.delay(1000 / speed);
    if (killed) {
          killed = false;
          return;
        }
  }
}

void off(){
  fill_solid(leds, NUM_LEDS, CRGB(0,0,0));
  FastLED.show();
}

void start_bluetooth(){
  BLEDevice::init("Music Strip");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE
  );
  pCharacteristic->setCallbacks(new CommandCallback());
  pService->start();
  pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->start();
}


void fade(CRGB palette[], int size) {
  for (int i = 0; i < size; i++) {
    CRGB from = palette[i];
    CRGB to = palette[(i + 1) % size];

    for (int j = 1; j <= steps; j++) {
      float r_change = ((float)(to.r - from.r) / steps) * j;
      float g_change = ((float)(to.g - from.g) / steps) * j;
      float b_change = ((float)(to.b - from.b) / steps) * j;

      CRGB currentColor = CRGB(from.r+(int)r_change, from.g+(int)g_change, from.b+(int)b_change);

      fill_solid(leds, NUM_LEDS, currentColor);
      FastLED.show();
      FastLED.delay(1000 / speed);  
      if (killed) {
          killed = false;
          return;
        }
    }
  }
}

void lightTask(void *parameter){
  bool on = true;
  while (true){
    switch (mode){
      case OFF:
        if (on){
          off();
          on = false;
        }
        break;
      case MANUAL:
        on = true;
        switch (manualAnim){
          case MANUAL_STATIC_SINGLE:
            static_single(curr_color);
            break;
          case MANUAL_FADE:
          
            fade(rainbow, 7);
            break;
          case MANUAL_SNAKE:
            snake(rainbow, 7);
            break;
          case MANUAL_SWAP:
            swap(rainbow, 7);
            break;
        }
        break;
      case SPOTIFY:
        on = true;
        switch (spotifyAnim){
          case SPOTIFY_FADE:
            fade(spotify_palette, spotify_size);
            break;
          case SPOTIFY_SNAKE:
            snake(spotify_palette, spotify_size);
            break;
          case SPOTIFY_SWAP:
            swap(spotify_palette, spotify_size);
            break;
        }
        break;
    }
    vTaskDelay(pdMS_TO_TICKS(10));
  }
}

void serialTestTask(void *parameter) {
  while (true){
    if (Serial.available()){
      String command = Serial.readStringUntil('\n');
      int colon = command.indexOf(':');
      if (colon == -1) {
        Serial.println("Invalid command format. Use key:value");
        continue;
      }
      String key = command.substring(0, colon);
      key.trim();
      String value = command.substring(colon + 1);
      value.trim();
      //keys can be speed, brightness, steps, mode, manual, spotify
      if (key == "speed"){
        speed = value.toInt();
      }
      if (key == "brightness"){
        brightness = value.toInt();
        FastLED.setBrightness(brightness);
      }
      if (key == "steps"){
        steps = value.toInt();
      }
      if (key == "mode"){
        if (value == "off") {
          mode = OFF;
        } else if (value == "manual") {
          mode = MANUAL;
        } else if (value == "spotify") {
          mode = SPOTIFY;
        } else {
          Serial.println("Invalid mode. Use off, manual, or spotify.");
          continue;
        }
      }
      if (key == "manual") {
        if (value == "static_single") {
          manualAnim = MANUAL_STATIC_SINGLE;
        } else if (value == "fade") {
          manualAnim = MANUAL_FADE;
        } else if (value == "snake") {
          manualAnim = MANUAL_SNAKE;
        } else if (value == "swap") {
          manualAnim = MANUAL_SWAP;
        } else {
          Serial.println("Invalid manual animation. Use static_single, fade, snake, or swap.");
          continue;
        }
      }
      if (key == "spotify") {
        if (value == "fade") {
          spotifyAnim = SPOTIFY_FADE;
        } else if (value == "snake") {
          spotifyAnim = SPOTIFY_SNAKE;
        } else if (value == "swap") {
          spotifyAnim = SPOTIFY_SWAP;
        } else {
          Serial.println("Invalid spotify animation. Use fade, snake, or swap.");
          continue;
        }
      }
      savePreferences();
    }
    vTaskDelay(pdMS_TO_TICKS(10));
  }
}


void setup() {
  Serial.begin(115200);
  delay(1000); 
  retrievePreferences();
  FastLED.addLeds<CHIPSET, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.setBrightness(brightness);
  //mode = MANUAL;
  //manualAnim = MANUAL_SWAP;
  start_bluetooth();
  xTaskCreatePinnedToCore(lightTask, "Light Task", 4096, NULL, 1, NULL,1);
  xTaskCreatePinnedToCore(serialTestTask, "Serial Test Task", 4096, NULL, 1, NULL, 0);
}

void loop() {
  // put your main code here, to run repeatedly:
}
