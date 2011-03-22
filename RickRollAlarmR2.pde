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
boolean isTimeSet = false;
boolean debugMode = true;

//Time varibles. Obsolete
int SetupDate = 0;
int SetupMonth = 0;
int SetupYear = 2000;
int SetupHour = 0;
int SetupMinute = 0;


//Time to sound the alarm. Should be replaced by a "Time" varible
int TargetHour = 0;
int TargetMinute = 0;
int TargetDate = 0;
int TargetYear = 2000;
int TargetMonth = 0;



void setup()
{
  Serial.begin(9600);    
  Serial.println("Device on standby, pending setup.");
  Serial.println("Set time to arm April Fools device. (Hour:Minute:Month(int):Date:Year:)");
  
  getSerialTimeData();
  
  /*
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
    //check that we indeed did get 5 colins
    if (timeIndex = 6) {
     isTimeSet = true; //breakout of loop
     clearTime();
     timeIndex = 0;
     
    } else {
     //clear it all and start over 
     clearTime();
     timeIndex = 0;
     clearBuffer();
     index = 0;
     Serial.println("Sorry, couldn't parse that input. Are you sure that you typed it correctly and included 6 colins? (You need a colin at the end of the command)");
    }
    
  } */
  
  
  
  setTime(time[0], time[1], 0, time[3], time[2], time[4]); // set time to Serialtime. 

  Serial.println("April Fools device now has the current time. Specify target time.");
  
  
  //needs cleaning before running.....
  getSerialTimeData();
  


  Serial.println("April Fools device is now armed. Commencing countdown.");


/*

  Alarm.alarmRepeat(8,30,0, MorningAlarm);  // 8:30am every day
  Alarm.alarmRepeat(17,45,0,EveningAlarm);  // 5:45pm every day 
 
  Alarm.timerRepeat(15, RepeatTask);            // timer for every 15 seconds    
  Alarm.timerOnce(10, OnceOnlyTask);            // called once after 10 seconds 
  */
}

void MorningAlarm()
{
  Serial.println("Alarm: - turn lights off");    
}



void  loop()
{  
  digitalClockDisplay();
  Alarm.delay(1000); // wait one second between clock display
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
    //check that we indeed did get 5 colins
    if (timeIndex = 6) {
     isTimeSet = true; //breakout of loop
     clearTime();
     timeIndex = 0;
     
    } else {
     //clear it all and start over 
     clearTime();
     timeIndex = 0;
     clearBuffer();
     index = 0;
     Serial.println("Sorry, couldn't parse that input. Are you sure that you typed it correctly and included 6 colins? (You need a colin at the end of the command)");
    }
    
  }
 
}

