//this code controls an ESP32 that communicates with a museum exhibit over i2c with the wire library
//I reprogrammed the exhibit to output visitor engagement data here via i2c, to then be sent to thingspeak
//on thingspeak, I have a graphic where visitors can visual their data compared to others that day

#include <ThingSpeak.h>
#include <Wire.h>
#include <WiFi.h>
#include "esp_wpa2.h" //wpa2 library for connections to Enterprise networks

// PRIVATE CREDENTIALS 
#define SECRET_CH_ID 573246     // Drop zone 1
#define SECRET_WRITE_APIKEY "UNKI6L5F78DQ0UAU"   // Drop zone 1
#define EAP_ANONYMOUS_IDENTITY "dcurley"
#define EAP_IDENTITY "dcurley"
#define EAP_PASSWORD "Summer19!"//will eventually need one that doesn't channge
const char* ssid = "MoS_Staff"; // Eduroam SSID
// END PRIVATE CREDENTIALS

WiFiClient  client;
int counter = 0;
unsigned long myChannelNumber = SECRET_CH_ID;
const char* myWriteAPIKey = SECRET_WRITE_APIKEY;
int bounce;

int test = 2; //input from arduino

void setup() {
  Serial.begin(115200);  //Initialize serial

  pinMode(test,INPUT); //input button
  
  Serial.print("Connecting to network: ");
  Serial.println(ssid);
  WiFi.disconnect(true);  //disconnect form wifi to set new wifi connection
  WiFi.mode(WIFI_STA); //init wifi mode
  
  ThingSpeak.begin(client);  // Initialize ThingSpeak

  //set up ESP32 Station
  esp_wifi_sta_wpa2_ent_set_identity((uint8_t *)EAP_ANONYMOUS_IDENTITY, strlen(EAP_ANONYMOUS_IDENTITY)); 
  esp_wifi_sta_wpa2_ent_set_username((uint8_t *)EAP_IDENTITY, strlen(EAP_IDENTITY));
  esp_wifi_sta_wpa2_ent_set_password((uint8_t *)EAP_PASSWORD, strlen(EAP_PASSWORD));
  esp_wpa2_config_t config = WPA2_CONFIG_INIT_DEFAULT(); //set config settings to default
  esp_wifi_sta_wpa2_ent_enable(&config); //set config settings to enable function
  
  WiFi.begin(ssid); //connect to wifi network under Enterprise 802.1x
  Wire.begin(); 
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    counter++;
    if(counter>=60){ //after 30 seconds timeout - reset board
      ESP.restart();
    }
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address set: "); 
  Serial.println(WiFi.localIP()); //print LAN IP for troubleshooting
}

void loop() {
  
int statusCode = 0;

  // Connect or reconnect to WiFi
 if(WiFi.status() != WL_CONNECTED){
    WiFi.begin(ssid);
  }else{
    if(counter!=0){
      counter = 0;
    }
  }
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    counter++;
    if(counter>=60){ //after 30 seconds timeout - reset board
      ESP.restart();
    }
  }

//--------------Wire communication with Museum Exhibit
if (digitalRead(test)){ //Arduino will send HIGH when the button is pushed
  Serial.println("Arduino button pushed! Sending request");
    Wire.requestFrom(8, 2);    // request 2 bytes from slave device #8
    while (1 < Wire.available()) { // slave may send less than requested
       bounce = Wire.read(); // receive a byte as character
      Serial.println(bounce);   //  print the character
    }
  Serial.print("Bounce Height=");
  Serial.println(bounce);

  //send data from exhibit to ThingsSpeak
  statusCode = ThingSpeak.writeField(myChannelNumber, 1, bounce, myWriteAPIKey);

  //thingspeak feedback for troubleshooting
  if(statusCode == 200){Serial.println("Channel was updated! OK!");
  }else if(statusCode == 404){
    Serial.println("Incorrect API key (or invalid ThingSpeak server address)");
  }else if(statusCode == -101){
    Serial.println("Value is out of range or string is too long (> 255 characters)");
  }else if(statusCode == -201){
    Serial.println("  Invalid field number specified");
  }else if(statusCode == -210){
    Serial.println("setField() was not called before writeFields()");
  }else if(statusCode == -301){
    Serial.println("Failed to connect to ThingSpeak");
  }else if(statusCode == -302){
    Serial.println("Unexpected failure during write to ThingSpeak");
  }else if(statusCode == -303){
    Serial.println("Unable to parse response");
  }else if(statusCode == -304 ){
    Serial.println("Timeout waiting for server to respond");
  }else if(statusCode == -401){
    Serial.println("Point was not inserted (most probable cause is the rate limit of once every 15 seconds)");
  }else{
    Serial.println("Unexpected error!"); }  
}
delay(200); // some wiggle room here. Fast enough where it doesn't delay
}
