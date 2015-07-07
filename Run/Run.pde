//-----------------------------------------------------------------
// Imports
//-----------------------------------------------------------------
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.util.Date;

//-----------------------------------------------------------------
// Variable Definitions
//-----------------------------------------------------------------
KeystrokeSimulator keySimulator; // Helper to simulate key events
Date lastActionDate = new Date(); // Time last action occured
Date currentDate; // Current date used for calculating time elapsed
float actionRepeatTime = 1500; // Amount of time before new action


//-----------------------------------------------------------------
// Setup
//-----------------------------------------------------------------
void setup()
{
  println("Initializing");
  keySimulator = new KeystrokeSimulator();
}

//-----------------------------------------------------------------
// Draw Method
//-----------------------------------------------------------------
void draw()
{
  slidePrevious();
}

//-----------------------------------------------------------------
// Powerpoint Functions
//-----------------------------------------------------------------
void slidePrevious() 
{
  println("Previous Slide");
  try {
    keySimulator.simulateEvent(KeyEvent.VK_P);
  }
  catch(AWTException e) {
    println(e);
  }
}

void slideNext()
{
  println("Next Slide");
  try {
    keySimulator.simulateEvent(KeyEvent.VK_N);
  }
  catch(AWTException e) {
    println(e);
  }
}

//-----------------------------------------------------------------
// Helping Classes
//-----------------------------------------------------------------
public class KeystrokeSimulator {
  private Robot robot;

  KeystrokeSimulator() {
    try {
      robot = new Robot();
    }
    catch(AWTException e) {
      println(e);
    }
  }

  void simulateEvent(int inputKey) throws AWTException {
    currentDate = new Date();
    if (currentDate.getTime() - lastActionDate.getTime() > actionRepeatTime)
    {
      robot.keyPress(inputKey);
      robot.keyRelease(inputKey);
      lastActionDate = new Date();
    }
  }
}

