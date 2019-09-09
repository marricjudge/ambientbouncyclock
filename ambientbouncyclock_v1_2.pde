/* AMBIENT BOUNCY CLOCK
 by Marius Richter
 
 Ambient visualization of absolute time in a creative way. 
 Bouncy Balls = Seconds // Rising screen = Minutes // Polygon edges = Hours // Color = Day of the year // 
 Press any key to display the current time - press again to hide.
 
 The 60 bouncing balls are the current seconds, every second one ball disappears and starts over when the minute is full.
 The grey layer visualizes the current minutes, rising continuously until the full hour. 
 The polygon wheel is the current hour, visualizing with its edges the passed hours of the day in the 24h format. 
 03:00 is a triangle, 08:00 an octagon and 19:00 an enneadecagon. 
 The background color is the current day of the year, fading from Jan to Dec through the Hue-Colorspace.
 Day 1 = Jan 1st, Day 2 = Jan 2nd, Day 31 = Feb 1st, etc. (every month has 30 days).

 Set your own custom time to test other moment within a year.
 Go to void setup(), uncomment the line "customTimeFlag = true;" and set your time below.
 Comment the line again to show the current time of your system.
 
 Fork and modify me!
 
 Version: 1.2
 Last Update: 05.12.2018 by Marius Richter
 */

//Libaries and variables
PFont font;
boolean timeDisplayFlag = false;
boolean customTimeFlag = false;
float globalFill = height;
int sec = second();
int h = hour();
int min = minute();
int currentDay = month()*30 + day(); //Calculates the current day within the year
int customSec, customMin, customHour, customDay; //Variables for custom set time
color polygoncolor;
color bgcolor;

Ball[] theBalls = new Ball [60]; //Create the 60 ball objects out of the Ball class

void setup() {
  // ##############MODIFIERS################### //
  //SET YOUR CUSTOM TIME HERE
  //customTimeFlag = true; //uncomment this line to activate the custom time
  customHour = 2; //Set your custom hour 24h format ('1' is 1am, '13' is 1pm)
  customMin  = 10; //Set your custom minute, limit is 60
  customSec  = 20; //Set your custom second, limit is 60
  customDay  = 250; //Set your custom day out of 360 (Day 1 = Jan 1st, Day 2 = Jan 2nd, Day 31 = Feb 1st, etc. Every month has 30 days)).

  //SET SCREEN MODE HERE, Uncomment the mode you want. Fullscreen recommended.
  fullScreen();
  //size(800, 800);
  // #############END#OF#MODIFIERS########### //

  colorMode(HSB, 360, 100, 100, 100); //HSB Color: Hue, Saturation, Brightness, Opacity
  frameRate(60); //Fixed 60 frames per second
  smooth(); //Anti-aliasing
  font = createFont("Arial", 16, true); // Arial, 16 point, anti-aliasing

  for (int i=0; i<60; i++) { // Initialize the bouncing balls
    theBalls[i] = new Ball(random(width), random(height), random(2), color(random(360), random(50, 80), random(80, 100), 80));
  }
} //End of void setup()

void draw() {
  // TIME UPDATE
  if (customTimeFlag == true) { //Sets the time to the custom set time if the stopflag is activated
    sec = customSec;
    min = customMin;
    h = customHour;
    currentDay = customDay;
  } else { //Set the time to the current system time
    h = hour();
    min = minute();
    sec = second();
    currentDay = month()*30 + day(); //Calculates the current day of the year - simplified to 360 days in a year
  }

  //Calculates the color for background and polygon based on the current day of the year
  bgcolor = color(currentDay, 100, 100, 20); //HSB Color: Hue, Saturation, Brightness, Opacity
  polygoncolor = color(currentDay, 80, 80, 30); //HSB Color: Hue, Saturation, Brightness, Opacity

  background(360, 0, 100, 100); //Sets the background to absolute clear white (0% Saturation, 100% Brightness)
  fill(bgcolor); 
  rect(0, 0, width, height); //Draw fullframe rect with the background color

  //MINUTES FILL
  rectMode(CORNERS);
  float minXsec = min*60 + sec; //Calculating the total sum of elapsed seconds within one hour. Number in seconds
  float fillStatus = map(minXsec, 0, 3600, 0, height); //Mapping the 3600 seconds of one hour to the height of the screen
  noStroke();
  fill(0, 10); //10% Opacity
  rect(0, height, width, (height-fillStatus)); //Draw a rect from the buttom that slowly grows upwards and is filled when the current hour is complete
  globalFill = (height-fillStatus); //Global variable 'globalFill' will be used for the bouncing ball limit

  // HOUR POLYGON
  pushMatrix();
  translate(width/2, height/2); //Sets the origin into the centre of screen
  fill(polygoncolor); //Polygoncolor for fill and stroke
  stroke(polygoncolor);
  strokeWeight(15);
  rotate(frameCount/TWO_PI/60); //Set the rotation time to exactly one minute (FrameRate set to 60fps)

  if (h == 0) { //Exception when the Hour is 0
    ellipse(0, 0, width/4, width/4);
    fill(bgcolor, 20);
    ellipse(0, 0, width/8, width/8);
  } else if (h == 1) { //Exception when the Hour is 1
    rectMode(CENTER);
    ellipse(0, 0, width/4, width/4);
    fill(bgcolor, 20);
    polygoncircles(0, 0, height/5, h);
  } else if (h == 2) { //Exception when the Hour is 2
    rectMode(CENTER);
    ellipse(0, 0, width/4, width/4);
    fill(bgcolor, 20);
    polygoncircles(0, 0, height/5, h);
  } else {  
    polygon(0, 0, height/4, h);  // Creates a polygon with the current minute set as the amount of corners (not for h = 0 OR 1 OR 2)
    polygoncircles(0, 0, height/5, h); //Draws the inner circles on each corner
  }
  popMatrix();

  //SECONDS: SPAWNING THE BOUNCY BALLS 
  rectMode(CORNER);
  for (int i= second(); i<60; i++) { //Loops through every ball
    theBalls[i].display(); //Will be displayed and updated
    theBalls[i].update();
  }

  // DISPLAY THE TIME ON SCREEN
  displayTime();

  //println(h +":"+ min +":"+ sec); //Print the current system time in the terminal
} //Close of void draw()

//BALL OBJECTS
class Ball {
  float x;   //Class members
  float y;
  float speed;
  color c;

  Ball(float x0, float y0, float s0, color c0) { //Class constructor
    x = x0;
    y = y0;
    speed = s0;
    c = c0;
  }
  void display() { //Display each object on the screen
    fill(c);
    noStroke();
    ellipse(x, y, 20, 20);
    y = y + speed;
    float gravity = 0.1;
    speed = speed + gravity;
  }
  void update() { //Update each displayed ball
    if (y > globalFill-10) { //10px offset for bouncing on the surface (20px diameter is each ball)
      speed = speed * -0.95;
      y = globalFill-10;
    }
  }
} //Close of Ball class

//POLYGON CONSTRUCTION (from https://processing.org/examples/regularpolygon.html)
void polygon(float x, float y, float radius, int npoints) { //Creates the Polygon, Function from https://processing.org/examples/regularpolygon.html
  float angle = TWO_PI / npoints;
  beginShape(); //Start constructing a shape
  for (float a = 0; a < TWO_PI; a += angle) { //Devide the 360 degrees by the amount of polygon corners
    float sx = x + cos(a) * radius; //Calc X and Y coordinates
    float sy = y + sin(a) * radius;
    vertex(sx, sy); //Conntects each polygon corner to one shape
  }
  endShape(CLOSE); //Close the shape constructor
} //Close of void polygon()

//CIRCLES IN THE POLYGON 
void polygoncircles(float x, float y, float radius, int npoints) { //Creates the innter circeles in the polygon
  float angle = TWO_PI / npoints;
  for (float a = 0; a < TWO_PI; a += angle) { //Devide the 360 degrees by the amount of polygon corners
    float sx = x + cos(a) * radius; //Calc X and Y coordinates
    float sy = y + sin(a) * radius;
    strokeWeight(5);
    ellipse(sx, sy, 10, 10); //Draw a circle on the calculation of every corner of the polygon
  }
} //Close of void polygoncircles()

//DISPLAY THE TIME
void displayTime() { //Function for displaying the current time on the screen if any key is pressed
  textAlign(CENTER, CENTER ); //Font settings
  textFont(font, height/16);
  fill(polygoncolor);

  int displayUpOrDown;  //Displaying the time eighter on screen top or bottom to not interfere with the bouncing balls
  if (min < 30) { 
    displayUpOrDown = (height/16);
  } else {
    displayUpOrDown = 15*(height/16);
  }

  if (timeDisplayFlag == true) {   //Only if stopflag is true (any key is pressed), default is false
    String displayHour = str(h);  //Converts current time number into string
    String displayMin = str(min);
    String displaySec = str(sec);
    if (h < 10) { //If he HOUR/minute/second is less then then a preceding 0 will be added to the string
      displayHour = "0" + h;
      if (min < 10) { //Special exception if hour is one digit, checks then the minute if a single digit
        displayMin = "0" + min;
      }
      if (sec < 10) { //Special exception if hour is one digit, checks then the second if a single digit
        displaySec = "0" + sec;
      }
    } else if (min < 10) { //MINUTE
      displayMin = "0" + min;
      if (sec < 10) { //Special exception if minute is one digit, checks then the second if a single digit
        displaySec = "0" + sec;
      }
    } else if (sec < 10) { //SECOND
      displaySec = "0" + sec;
    }
    text(displayHour +":"+ displayMin +":"+ displaySec, width/2, displayUpOrDown); //Display the time
  }
} //Close void displayTime()

void keyPressed() { //If any key is pressed the stopflag will be inverted and text will appear/disappear
  if (timeDisplayFlag == false) {
    timeDisplayFlag = true;
  } else {
    timeDisplayFlag = false;
  }
} //Close void keyPressed()

void mousePressed() { //Mouse clicks refer to the same as a key press
  keyPressed();
}


/* SOURCES
 https://processing.org/examples/regularpolygon.html - accessed 01.12.2018
 https://www.openprocessing.org/sketch/635808 - accessed 01.12.2018
 https://en.wikipedia.org/wiki/Vertex_(geometry) - accessed 01.12.2018
 https://processing.org/tutorials/text/ - accessed 02.12.2018
 https://processing.org/examples/datatypeconversion.html - accessed 02.12.2018
 https://funprogramming.org/17-A-better-way-to-generate-random-colors.html - accessed 03.12.2018
 https://forum.processing.org/two/discussion/3489/how-to-create-an-array-of-pre-defined-colors - accessed 03.12.2018
 https://processing.org/discourse/beta/num_1251914723.html - accessed 03.12.2018
 https://forum.processing.org/two/discussion/7988/clear-an-object-on-the-screen-by-keypress - accessed 03.12.2018
 https://processing.org/tutorials/arrays/ - accessed 03.12.2018
 SM2715 Course Material Sourcecode (week9_absandrealtive; wk9_example3a; wk7_example1a; week10_oocar; wk10_example_01_d_many_cars; wk10_example_02_a_simple_gravity)
 and the Processing.org Reference Documentation
 */
