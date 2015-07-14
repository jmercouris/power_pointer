//-----------------------------------------------------------------
// Imports
//-----------------------------------------------------------------
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.util.Date;
import SimpleOpenNI.*;
import muthesius.net.*;
import org.webbitserver.*;
import java.awt.Toolkit;
import ddf.minim.*;

//-----------------------------------------------------------------
// Variable Definitions
//-----------------------------------------------------------------
KeystrokeSimulator keySimulator; // Helper to simulate key events
Date lastActionDate = new Date(); // Time last action occured
Date currentDate; // Current date used for calculating time elapsed
float actionRepeatTime = 1500; // Amount of time before new action
SimpleOpenNI  context; // Reference to openNI Library
PVector vectorPoint = new PVector(); // Reusable vector for tracking
PVector vectorCore = new PVector(); // Reusable vector for tracking
WebSocketP5 socket; // Web socket for communicating with chrome
Minim minim; // Minim Library Instance
AudioPlayer song; // Audio player for feedback


// Colors of incremental users
color[] userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

//-----------------------------------------------------------------
// Setup
//-----------------------------------------------------------------
void setup()
{
  println("Initializing");
  keySimulator = new KeystrokeSimulator();

  // Attempt to Instantiate SimpleOpenNI
  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI"); 
    exit();
    return;
  }

  // Initialization
  size(640, 480);
  context.enableDepth();
  context.enableUser();
  context.setMirror(true);

  // Setup Voice Control
  socket = new WebSocketP5(this, 8080);

  // Setup Audio Playback
  minim = new Minim(this);

  // Set Drawing information
  background(200, 0, 0);
  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();
}

//-----------------------------------------------------------------
// Draw Method
//-----------------------------------------------------------------
void draw()
{
  // Update the Camera
  context.update();
  image(context.userImage(), 0, 0);

  // Reduce Frame Checking Rate
  if (frameCount % 30 == 0) {
    int[] userList = context.getUsers();
    for (int i=0; i<userList.length; i++)
    {
      // Detect Gesture Left or right
      if (context.isTrackingSkeleton(userList[i]))
      {
        stroke(userClr[ (userList[i] - 1) % userClr.length ] );
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, vectorPoint);
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_TORSO, vectorCore);
        if (abs(vectorPoint.x - vectorCore.x) > 300 && vectorPoint.y > vectorCore.y)
        {
          slideNext();
        } 
        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, vectorPoint);
        if (abs(vectorPoint.x - vectorCore.x) > 300 && vectorPoint.y > vectorCore.y)
        {
          slidePrevious();
        }
      }
    }
  }
}

//-----------------------------------------------------------------
// Web Socket Receieved Message
//-----------------------------------------------------------------
void websocketOnMessage(WebSocketConnection con, String msg) {
  println(msg);

  if (msg.contains("next"))
  {
    slideNext();
  }
  if (msg.contains("previous"))
  {
    slidePrevious();
  }
}

//-----------------------------------------------------------------
// Stop
//-----------------------------------------------------------------
void stop() {
  socket.stop();
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
// Helping Classes & Functions
//-----------------------------------------------------------------
// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
   println(jointPos);
   */

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}
//-----------------------------------------------------------------
// SimpleOpenNI events
//-----------------------------------------------------------------
void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);

  // Alert user tracking began
  song = minim.loadFile("connected.mp3");
  song.play();
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);

  // Alert user tracking lost
  song = minim.loadFile("disconnected.mp3");
  song.play();
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

//-----------------------------------------------------------------
// Web Socket events
//-----------------------------------------------------------------
void websocketOnOpen(WebSocketConnection con) {
  println("A client joined");
}

void websocketOnClosed(WebSocketConnection con) {
  println("A client left");
}

//-----------------------------------------------------------------
// Keystroke Simulator Class
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
      // Alert user command received
      song = minim.loadFile("command.mp3");
      song.play();
      robot.keyPress(inputKey);
      robot.keyRelease(inputKey);
      lastActionDate = new Date();
    }
  }
}

