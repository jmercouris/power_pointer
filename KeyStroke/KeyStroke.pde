import java.awt.AWTException;
import java.awt.Robot;
 
KeystrokeSimulator keySim;
 
void setup(){
  keySim = new KeystrokeSimulator(); 
}
 
void draw(){
  try{
    keySim.simulate('['); 
  }
  catch(AWTException e){
    println(e);
  }
}
 
import java.awt.Robot;
import java.awt.AWTException;
 
public class KeystrokeSimulator {
 
private Robot robot;
  
  KeystrokeSimulator(){
    try{
      robot = new Robot();  
    }
    catch(AWTException e){
      println(e);
    }
  }
  
  void simulate(char c) throws AWTException {
    for (int i=0; i<10; i++) {
      robot.delay(1000);
      robot.keyPress(c);
    }
  }
}

