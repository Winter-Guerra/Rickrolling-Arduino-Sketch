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

boolean isTimeSet = false;
boolean debugMode = true;


void setup()
{
  Serial.begin(9600);    
  Serial.println("Device on standby, pending setup.");
  Serial.println("Set time to arm April Fools device. (Hour:Minute:Month(int):Date:Year)");

  getSerialTimeData();

  setTime(time[0], time[1], 0, time[3], time[2], time[4]); // set time to Serialtime. 

  Serial.println("April Fools device now has the current time:");
  Serial.println(time[0] +':'+ time[1] + ' ' + time[2] +'/'+ time[3] +'/'+ time[4]);
  clearTime();
  Serial.println("Set the target time!(same format)");
  
  getSerialTimeData();
  //set the timer!

  Serial.println("April Fools device is now armed. Commencing countdown.");

}


void  loop()
{  
  if (debugMode) { //if we are in the debugging mode
  digitalClockDisplay();  //display the time once every few seconds.
  }
  
  Alarm.delay(1000); // wait one second between clock display
}

void MorningAlarm()
{
  Serial.println("Alarm: - turn lights off");    
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

void clearTime() { //Clears the timesetup varible. (For unsucessful syncs)
  for (int i = 0; i < 5; i++) {
    time[i] = 0;
  }
}

void getSerialTimeData() { //Gets a serial time from serial. used for settings of alarm and syncing.
   //wait now for input.
  while(!Serial.available()) {delay(200);}
  
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
    } else { //if we see a divider. Calculate the recieved value and store it in a varible
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
     
    } else {
     //clear it all and start over 
     clearTime();
     timeIndex = 0;
     clearBuffer();
     index = 0;
     Serial.println("Sorry, couldn't parse that input. Are you sure that you typed it correctly and included 5 colins? (You do not need a colin at the end of the command)");
    }
    
  }
 
}

