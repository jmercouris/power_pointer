//-----------------------------------------------------------------
// Imports
//-----------------------------------------------------------------
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

//-----------------------------------------------------------------
// Variable Definitions
//-----------------------------------------------------------------
KeystrokeSimulator keySimulator;


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
      robot.keyPress(inputKey);
      robot.keyRelease(inputKey);
  }
}

