/*
 * TimeAlarmExample.pde
 *
 This program asks for the time and day via serial and then updates the serial with the current date and time (for debuging purposes)
 Then at a preset time it pulses a pin that is connected to a chipcorder and it rickrolls! Happy Rickrolling!
 */

#include <Time.h>
#include <TimeAlarms.h>

char buffer[100]; //serial buffer.

int time[5]; //TIme buffer, stores time except for seconds  
int triggerTime[5]; //TIme buffer, stores time except for seconds

time_t triggerTimeSecs; //Trigger Time in seconds. 
time_t setTimeTemp; //Current time to set 

int *arrayPointer[] = {triggerTime};

boolean isTimeSet = false;
boolean debugMode = true;
boolean alarmInProgress = false;

long delayMillis = 0;

#define RICKROLL_MINUTES      10 //Number of minutes to rickroll for.
#define RICKROLL_REPEAT_DELAY 2  //Minutes to wait before Rickrolling again.
#define CHIPCORDER_PIN        10 //The pin that the chipcorder is connected to.

///Array setup:
///0 = hour; 1 = minute; 2 = month; 3 = date; 4 = year.


void setup()
{
  Serial.begin(9600);    
  
  //Read previously saved time from EEPROM
  
  //Write the current time to the serial terminal.
  
  //Set Pinmodes:
  pinMode(CHIPCORDER_PIN, OUTPUT);
  digitalWrite(CHIPCORDER_PIN, LOW);
  
  Serial.println("Device on standby, pending setup.");
  
  Serial.println("Set time to arm April Fools device. (Hour:Minute:Month(int):Date:Year)");

  getSerialTimeData();

  setTime(time[0], time[1], 0, time[3], time[2], time[4]); // set time to Serialtime. 

  Serial.println("April Fools device now has the current time:");
  Serial.println(time[0] +':'+ time[1] + ' ' + time[2] +'/'+ time[3] +'/'+ time[4]);
  
  setTimeTemp = now(); //get the current time in seconds.

  clearTime(); //Get ready for the next command!
  Serial.println("Set the target time!(same format)");

  getSerialTimeData(); //Get input for trigger time.
  
  setTime(time[0], time[1], 0, time[3], time[2], time[4]); // set time to Serialtime. 

  triggerTimeSecs = now(); //get the trigger time

  Serial.println("April Fools device now has the target time:");
  Serial.println(time[0] +':'+ time[1] + ' ' + time[2] +'/'+ time[3] +'/'+ time[4]);
  
  setTime(setTimeTemp); //set time back again.

  Serial.println("April Fools device is now armed. Commencing countdown.");

  if (debugMode) Serial.println("Debug mode is on. Expect a clock output every few seconds with the current time.");

}


void loop() {  

  if (debugMode) { //if we are in the debugging mode
    digitalClockDisplay();  //display the time once every few seconds.
  }

  //Check for trigger conditions.
  if (alarmsTriggered()) {
    //Automated Rickrolling madness!
    rickRollCrashAndBurn(); //should this continue for a few minutes? Probably! ;) 
  }

  Alarm.delay(30000); // wait 30 seconds between everything. This might use up too much battery. Maybe just a big 'ol delay? Or amybe just a full on sleep 30?
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
  if(digits < 10)
    Serial.print('0');
  Serial.print(digits);
}

void clearBuffer() { //clears the serial buffer varible
  for (int i = 0; i < 100; i++) {
    buffer[i] = '\0';
  }
}

boolean triggerTimeReached() {
  //check time
 //I need to make a time secs subroutine to handle the packing!!!!!!!
  if (setTimeTemp >= triggerTimeSecs && setTimeTemp <= triggerTimeSecs + (RICKROLL_MINUTES*60))) {
    //Yay! we are on the right time!
    return true; 
  } 
  else return false;
}

boolean alarmsTriggered() {
  //returns a boolean whether the alarms have been triggered or not. It should also probably pass a enum too.
  if (triggerTimeReached()) {
    return true;
  } 
  else return false;


}

void rickRollCrashAndBurn() {
  //RickRoll!
 //wait the two minutes between rickrolls
 if (millis() > delayMillis + (RICKROLL_REPEAT_DELAY*60)) {
   //reset the millis timer
   delayMillis = millis();
   
   //pulse the output pin.
   digitalWrite(CHIPCORDER_PIN, HIGH);
   delay(1000);
   digitalWrite(CHIPCORDER_PIN, LOW);
 }

}

void clearTime() { //Clears the timesetup varible. (For unsucessful syncs)
  for (int i = 0; i < 5; i++) {
    time[i] = 0;
  }
}

void getSerialTimeData() { //Gets a serial time from serial. used for settings of alarm and syncing.
  //Don't wait for input. Just check and move onto the main prog loop.

  char tempChar;
  //While we still have input. Chop up the input

  int index = 0;
  int timeIndex = 0;

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
        clearBuffer();
        index = 0;
      }
    }
    //done recieving from host computer,
    //Add the remaining value (Year)
    time[timeIndex] = atoi(buffer);
    timeIndex++;
    //clear the buffer
    clearBuffer();
    index = 0;

    //check that we indeed did get 5 colins
    if (timeIndex = 5) {
      isTimeSet = true; //breakout of loop
      timeIndex = 0;
      clearBuffer();
      index = 0;
      Serial.println("Time recieved and set!");

    } 
    else {
      //clear it all and start over 
      clearTime();
      timeIndex = 0;
      clearBuffer();
      index = 0;
      Serial.println("Sorry, couldn't parse that input. Are you sure that you typed it correctly and included 5 colins? (You do not need a colin at the end of the command)");
    }

  }

}



