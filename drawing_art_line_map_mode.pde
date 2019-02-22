import gab.opencv.*;
import processing.video.*;
import processing.serial.*;
import static javax.swing.JOptionPane.*;

Capture video;
OpenCV opencv;
Histogram histogram;
Serial myPort;

ArrayList<Contour> contours;
int counter=0;
int[] limit= new int[3];
PImage src, temp, logo, logo_show;
PrintWriter output;
boolean oked = true, posMoved = false, serial_out=false;
boolean selecting = true, preparing= true, selected=false, debug = true;
int forLoop = 0;
String[] gcodes;
int working_mode = 0;
String path, COMx, COMlist = "";
int pen_up = 125, pen_down= 145;
float _scale;


void setup() {
  oked = true; 
  posMoved = false; 
  serial_out=false;
  selecting = true; 
  preparing= true;
  selected=false;
  debug = true;

  size(975, 450);
  surface.setResizable(true);
  background(204);
  pixelDensity(displayDensity());
  imageMode(CORNER);
  textAlign(CENTER);
  textSize(14);
  //logo = loadImage("logo.png");
  //logo_show = loadImage("logo_show.png");
  text("Please Press the keyboard to Select Working Mode:\n 1. Live Webcam Mode   2. Photo Mode    3. Machine setting", 100, 100);
  text("Pen UP = "+ pen_up+"       Pen DOWN = "+pen_down, 100, 200);
  //image(logo_show, width-74*2, height-23*2, 74*2, 23*2);
  println("Please Press the keyboard to Select Working Mode:\n 1. Live Webcam Mode   2. Photo Mode    3. Machine setting");
  println("Pen UP = "+ pen_up+"       Pen DOWN = "+pen_down);
 
  output = createWriter("positions.txt");
}

void draw() {
  if (selecting == false && preparing == true) {
    if (working_mode == 2) {
      println("working mode = photo mode");
      selectInput("Select a file to process:", "fileSelected");
      serial_select();
    }
    if (working_mode ==1) {
      println("working mode = live webcam mode");
      println(Capture.list());
      video = new Capture(this, 1280, 720);
      video.start();
      src = video.get();
      _scale = float(src.height)/float(src.width); 
      surface.setSize(975, int(975*_scale));  //100dpi=3.937dpmm, 250mm*3.9dpmm= 975pixel 
      src.resize(width, height);
      opencv = new OpenCV(this, src);
      selected = true;
      serial_select();
    }

    preparing = false;
    println("ready to go");
  }
  if (preparing == false && selected == true) {
    if (working_mode ==3) {
      background(205);
      pen_up =int(map(mouseX, 0, width, 0, 180));
      pen_down =int(map(mouseY, 0, height, 0, 180));
      textAlign(CENTER);
      textSize(12);
      text("move mouseX and mouseY to select the servo UP and DOWN \n Pen UP = "+ pen_up+"       Pen DOWN = "+pen_down+"\n Press ENTER to comfirm", width/2, height/2);
    } else {
      if (working_mode ==1) {
        src = video.get();
        float _scale = float(src.height)/float(src.width); 
        surface.setSize(975, int(975*_scale));
        src.resize(width, height);
      }
      if (serial_out == true) {
        
        //do nothing, wait for drawing

      } else {
        if (counter <=2) { 
          int max = (int)map(mouseX, 0, width, 0, 255);
          limit[0]=max*3/4;
          limit[1]=max/2;
          limit[2]=max/4;
          drawh();
        } 
        if (counter == 3) {
          draw_shadow();
          screen_output();
        }
      }
    }
  }
}


void captureEvent(Capture c) {
  c.read();
}