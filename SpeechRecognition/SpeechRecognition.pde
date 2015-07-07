/*
  Simple WebSocketServer example that can receive voice transcripts from Chrome
 */
 
import muthesius.net.*;
import org.webbitserver.*;
 
WebSocketP5 socket;
 
void setup() {
  socket = new WebSocketP5(this,8080);
}
 
void draw() {}
 
void stop(){
  socket.stop();
}
 
void websocketOnMessage(WebSocketConnection con, String msg){
  println(msg);
  if (msg.contains("hello")) println("Yay!");
}
 
void websocketOnOpen(WebSocketConnection con){
  println("A client joined");
}
 
void websocketOnClosed(WebSocketConnection con){
  println("A client left");
}

