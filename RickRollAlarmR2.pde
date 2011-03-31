/*
 * TimeAlarmExample.pde
 *
 This program asks for the time and day via serial and then updates the serial with the current date and time (for debuging purposes)
 Then at a preset time it pulses a pin that is connected to a chipcorder and it rickrolls! Happy Rickrolling!
 */

#include <Time.h>
#include <TimeAlarms.h>
#include <avr/eeprom.h>


String password, passwordTry;

int time[5]; //TIme buffer, stores time except for seconds  
int triggerTime[5]; //TIme buffer, stores time except for seconds

time_t triggerTimeSecs = 0; //Trigger Time in seconds. 
time_t setTimeTemp; //Current time to set 

boolean isTimeSet = false;
boolean debugMode = true;
boolean alarmInProgress = false;

unsigned long delayMillis = 0;

#define RICKROLL_MINUTES      10 //Number of minutes to rickroll for.
#define RICKROLL_REPEAT_DELAY 24  //Seconds to wait before Rickrolling again.
#define CHIPCORDER_PIN        2 //The pin that the chipcorder is connected to.

///Array setup:
///0 = hour; 1 = minute; 2 = month; 3 = date; 4 = year.


void setup()
{
  Serial.begin(9600);    

  Serial.println("Read current time from EEPROM....");
  
  //Read previously saved time from EEPROM
   int16_t offset; //this is where in eeprom we should start saving/reading.
   offset = 0x00;
   eeprom_read_block((void*)&setTimeTemp, (const void*)offset, 4); //read it from eeprom
   
   offset = 0x04;
   eeprom_read_block((void*)&triggerTimeSecs, (const void*)offset, 4); //read it from eeprom
   
   Serial.println("Done!");
   
   setTime(setTimeTemp); // set time to EEPROM 

  Serial.println("The current time is:");
  //digitalClockDisplay();
  
  //setupTheCurrentTimeThroughSerial();


  //Set Pinmodes:
  pinMode(CHIPCORDER_PIN, OUTPUT);
  digitalWrite(CHIPCORDER_PIN, LOW);

  
 Serial.println("Device on standby, pending setup. Password please?");
}


void loop() {  

  //check if there is anything coming in the serial port (like a password!)
 

  if (debugMode) { //if we are in the debugging mode
    digitalClockDisplay();  //display the time once every few seconds.
  }

  //Check for trigger conditions.
    //Automated Rickrolling madness!
    rickRollCrashAndBurn(); //should this continue for a few minutes? Probably! ;) 
 
  setTimeTemp = now(); //get the current time in seconds.

  int16_t offset; //this is where in eeprom we should start saving/reading.
  offset = 0x00;
  eeprom_write_block((const void*)&setTimeTemp, (void*)offset, 4);


  delay(1000); // wait 30 seconds between everything. This might use up too much battery. Maybe just a big 'ol delay? Or amybe just a full on sleep

}



void digitalClockDisplay()
{
  // digital clock display of the time
  //(Hour:Minute:Seconds:Month(int):Date:Year:)"
  Serial.print(hour());
  printDigits(minute());
  printDigits(second());
  printDigits(month());
  printDigits(day());
  printDigits(year());
  Serial.println(); 
}

void printDigits(int digits)
{
  // utility function for digital clock display: prints preceding colon and leading 0
  Serial.print(":");
  if (digits < 10)
    Serial.print('0');
  Serial.print(digits);
}

boolean triggerTimeReached() {
  //check time
  //I need to make a time secs subroutine to handle the packing!!!!!!!
  if (now() > triggerTimeSecs && now() < triggerTimeSecs + (RICKROLL_MINUTES*60)) {
    //Yay! we are on the right time!
    return true; 
  } 
  else return false;
}

boolean getPassword() {
  //checks the serial input to see if its the password. If not, then break out and do not allow any changes.
  char tempChar;
  int index = 0;
  char buffer[40];

  delay(100); //delay to allow the serial data to filter in.

  while (Serial.available()) { //get the serial data.
    buffer[index] = Serial.read();
    index++; 
  } 

  passwordTry = buffer[0]; //clear the password try
  for (int i = 1; i <index; i++) { //turn it into a string
    passwordTry += buffer[i];
  }
  for (int i = 0; i < 40; i++) {
       buffer[i] = '\0'; 
      }
  if (password == passwordTry) { //is it the password?
    return true; 
  } 
  else {
    return false; 
  }

}

void rickRollCrashAndBurn() {
  Serial.println("Checking.");
  if (now() > triggerTimeSecs && now() < triggerTimeSecs + (RICKROLL_MINUTES*60)) {
    Serial.println("Time is right.");
  //RickRoll!
  //wait the 30secs minutes between rickrolls
  if (millis() > delayMillis + (RICKROLL_REPEAT_DELAY*1000)) {
    Serial.println("Detonate!");
    //reset the millis timer
    delayMillis = millis();

    //pulse the output pin.
    digitalWrite(CHIPCORDER_PIN, HIGH);
    delay(1000);
    digitalWrite(CHIPCORDER_PIN, LOW);
  }
  }
}

void clearTime() { //Clears the timesetup varible. (For unsucessful syncs)
  for (int i = 0; i < 5; i++) {
    time[i] = 0;
  }
}

void setupTheCurrentTimeThroughSerial() {
  //check if there is data and save it.

  Serial.println("Set time to arm April Fools device. (Hour:Minute:Month(int):Date:Year)");

  getSerialTimeData();

  setTime(time[0], time[1], 0, time[3], time[2], time[4]); // set time to Serialtime. 

  Serial.println("April Fools device now has the current time:");
  Serial.println(now());

  setTimeTemp = now(); //get the current time in seconds.

  //Save it in EEPROM
  int16_t offset; //this is where in eeprom we should start saving/reading.
  offset = 0x00;
  eeprom_write_block((const void*)&setTimeTemp, (void*)offset, 4);

  clearTime(); //Get ready for the next command!
  Serial.println("Set the target time!(same format)");

  getSerialTimeData(); //Get input for trigger time.
  setTimeTemp = now(); //get the current time in seconds.

  setTime(time[0], time[1], 0, time[3], time[2], time[4]); // set time to Serialtime. 

  triggerTimeSecs = now(); //get the trigger time

  //Save into EEPROM
  offset = 0x04;
  eeprom_write_block((const void*)&triggerTimeSecs, (void*)offset, 4);

  Serial.println("April Fools device now has the target time:");
  Serial.println(now());

  setTime(setTimeTemp); //set time back again.

  //Save time into EEPROM

  Serial.println("April Fools device is now armed. Commencing countdown.");

  if (debugMode) Serial.println("Debug mode is on. Expect a clock output every few seconds with the current time.");
}



void getSerialTimeData() { //Gets a serial time from serial. used for settings of alarm and syncing.
  //Don't wait for input. Just check and move onto the main prog loop.
  while (!Serial.available()) {
    delay(1000); 
  }

  char tempChar;
  char buffer[40]; //serial buffer.
  //While we still have input. Chop up the input

  int index = 0;
  int timeIndex = 0;
  isTimeSet = false;

  while(!isTimeSet) {
    while(Serial.available()) {
      tempChar = Serial.read();
      if (tempChar != ':') {
        buffer[index] = tempChar;
        index++; 
      } 
      else { //if we see a divider. Calculate the recieved value and store it in a varible
        time[timeIndex] = atoi(buffer);
        timeIndex++;
        //clear the buffer
        for (int i = 0; i < 40; i++) {
       buffer[i] = '\0'; 
      }
        index = 0;
      }
    }
    //done recieving from host computer,
    //Add the remaining value (Year)
    time[timeIndex] = atoi(buffer);
    timeIndex++;
    //clear the buffer
    for (int i = 0; i < 40; i++) {
       buffer[i] = '\0'; 
      }
    index = 0;

    //check that we indeed did get 5 colins
    if (timeIndex = 5) {
      isTimeSet = true; //breakout of loop
      timeIndex = 0;
      for (int i = 0; i < 40; i++) {
       buffer[i] = '\0'; 
      }
      index = 0;
      Serial.println("Time recieved and set!");

    } 
    else {
      //clear it all and start over 
      clearTime();
      timeIndex = 0;
      for (int i = 0; i < 40; i++) {
       buffer[i] = '\0'; 
      }
      index = 0;
      Serial.println("Sorry, couldn't parse that input. Are you sure that you typed it correctly and included 5 colins? (You do not need a colin at the end of the command)");
    }

  }
}







