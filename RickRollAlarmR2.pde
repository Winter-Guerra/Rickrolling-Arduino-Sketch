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

int *arrayPointer[] = 

boolean isTimeSet = false;
boolean debugMode = true;

#define RICKROLL_MINUTES 10 //Number of minutes to rickroll for.

///Array setup:
///0 = hour; 1 = minute; 2 = month; 3 = date; 4 = year.


void setup()
{
  Serial.begin(9600);    
  Serial.println("Device on standby, pending setup.");
  Serial.println("Set time to arm April Fools device. (Hour:Minute:Month(int):Date:Year)");

  getSerialTimeData();

  setTime(time[0], time[1], 0, time[3], time[2], time[4]); // set time to Serialtime. 

  Serial.println("April Fools device now has the current time:");
  Serial.println(time[0] +':'+ time[1] + ' ' + time[2] +'/'+ time[3] +'/'+ time[4]);

  clearTime(); //Get ready for the next command!
  Serial.println("Set the target time!(same format)");

  getSerialTimeData(); //Get input. Perhaps a pointer would be better so I can store it directly to triggertime?
  //set the timer!
  for (int i = 0; i < 5; i++) {
    triggerTime[i] = time[i]; //get new trigger time
  }

  Serial.println("April Fools device now has the target time:");
  Serial.println(triggerTime[0] +':'+ triggerTime[1] + ' ' + triggerTime[2] +'/'+ triggerTime[3] +'/'+ triggerTime[4]);

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

  Alarm.delay(30000); // wait 30 seconds between everything. This might use up too much battery. Maybe just a big 'ol delay?
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

boolean triggerDateReached() {
  //Check date
  if (triggerTime[2] == month() && triggerTime[3] == day() && triggerTime[4] == year()) {
    //We are on the right date!
    return true;
  } 
  else return false;
}

boolean triggerTimeReached() {
  //check time
  if (triggerTime[0] == hour() && triggerTime[1] == minute()) {
    //Yay! we are on the right time!
    return true; 
  } 
  else return false;
}

boolean alarmsTriggered() {
  //returns a boolean whether the alarms have been triggered or not. It should also probably pass a enum too.
  if (triggerDateReached() && triggerTimeReached()) {
    return true;
  } 
  else return false;


}

void rickRollCrashAndBurn() {
  //RickRoll!
  //Read the time to keep pestering from the RICKROLL_MINUTES var.

}

void clearTime() { //Clears the timesetup varible. (For unsucessful syncs)
  for (int i = 0; i < 5; i++) {
    time[i] = 0;
  }
}

void getSerialTimeData() { //Gets a serial time from serial. used for settings of alarm and syncing.
  //wait now for input.
  while(!Serial.available()) {
    delay(200);
  }

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



