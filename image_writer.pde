void draw_shadow() {
  noFill(); 

  for (int i=0; i<=2; i++) {
    opencv.loadImage(src);
    opencv.useColor(HSB); 

    opencv.setGray(opencv.getB().clone());
    opencv.threshold(limit[i]);
    background(255);
    image(opencv.getOutput(), 0, 0, width, height);
    //image(logo,0, height-126, 400, 126);
    stroke(255);
    strokeWeight(2);
    if (i ==0)  
    {
      for (int j=0; j <=width*2; j+=5)
        line(j, 0, 0, j);
      save("limit_1.bmp");
    }
    if (i ==1)  
    {
      for (int j=0; j <=width; j+=5) {
        line(j, 0, width, width-j);
        line(0, j, width-j, width);
      }
      save("limit_2.bmp");
    }
    if (i ==2) {
      strokeWeight(2.5);
      for (int j=0; j <=width; j+=4)
        line(0, j, width, j);
      save("limit_3.bmp");
    }
  }
}

void drawh() {
  opencv.loadImage(src);
  opencv.useColor(HSB); 
  opencv.setGray(opencv.getB().clone());
  opencv.threshold(limit[counter]);
  image(opencv.getOutput(), 0, 0, width, height);
  histogram = opencv.findHistogram(opencv.getB(), 255);

  stroke(#00FF00);
  histogram.draw(0, height -230, width, 200);
  fill(#FF0000); 
  stroke(#FF0000);
  line(0, height-30, width, height-30);
  text("Brightness", 0, height - (textAscent() + textDescent()));

  float ll = map(limit[0], 0, 255, 0, width);
  float lsl = map(limit[1], 0, 255, 0, width);
  float ul = map(limit[2], 0, 255, 0, width);

  stroke(255, 0, 0); 
  fill(255, 0, 0);
  strokeWeight(2);

  ellipse(ll, height-30, 3, 3 );
  text(limit[0], ll-10, height-15);
  ellipse(lsl, height-30, 3, 3 );
  text(limit[1], lsl+10, height-15);
  ellipse(ul, height-30, 3, 3 );
  text(limit[2], ul+10, height-15);
  textSize(12);
  text("Move mouseX to adjust, press SPACEBAR 3 times to comfrim", width/2, 16);
  //image(logo_show, 0, 0, 74*3, 23*3);
}

void screen_output() {
  background(255);

  for (int i = 0; i<=2; i++) {
    if (i==0) temp= loadImage("limit_1.bmp");
    else if (i==1) temp = loadImage("limit_2.bmp");
    else if (i==2) temp = loadImage("limit_3.bmp");
    temp.resize(width, height);
    opencv.loadImage(temp);
    opencv.threshold(200);
    opencv.getOutput();
    contours = opencv.findContours();
    for (Contour contour : contours) {
      noFill();
      strokeWeight(1);
      stroke(0);
      beginShape();
      if (contour.area() >10) {
        for (PVector point : contour.getPoints()) {
          vertex(point.x, point.y);
        }
        endShape();
      }
    }
  }
  opencv.loadImage(src);
  opencv.findCannyEdges(mouseX, mouseY);
  contours = opencv.findContours();
  for (Contour contour : contours) {
    noFill();
    strokeWeight(1); 
    stroke(0);

    beginShape();
    for (PVector point : contour.getPoints ()) {
      vertex(point.x, point.y);
    }
    endShape();
  }
  textAlign(CENTER);
  textSize(12);
  text("move mouseX and mouseY to adjust, press ENTER to draw \n Press SPACEBAR to go back", width/2, 16);
  //image(logo_show, 0, 0, 74*5, 23*5);
  image(src, width-200, 0, 200, int(200*_scale));
} 


void printer_output() {
  background(255);
  for (int i = 0; i<=2; i++) {
    if (i==0) temp= loadImage("limit_1.bmp");
    else if (i==1) temp = loadImage("limit_2.bmp");
    else if (i==2) temp = loadImage("limit_3.bmp");
    temp.resize(width, height);
    opencv.loadImage(temp);
    opencv.threshold(200);
    opencv.getOutput();
    contours = opencv.findContours();
    for (Contour contour : contours) {
      if (contour.area() >10) {
        for (PVector point : contour.getPoints()) {
          point.x = point.x /3.937 + 10; //scale 100dpi
          point.y = point.y /3.937 + 10; //scale 100dpi
          output.println("G0 " + "X"+ point.x + " Y" +point.y + " Z0" + " F1000"); // Write the coordinate to the file
          if (!posMoved) {
            output.println("M03 S"+ pen_down);
            posMoved = true;
          }
        }
        output.println("M03 S"+ pen_up);
        posMoved = false;
      }
    }
  }
  opencv.loadImage(src);
  opencv.findCannyEdges(mouseX, mouseY);
  contours = opencv.findContours();
  for (Contour contour : contours) {
    for (PVector point : contour.getPoints()) {
      point.x = point.x /3.937 + 10; //scale 100dpi
      point.y = point.y /3.937 + 10; //scale 100dpi
      output.println("G0 " + "X"+ point.x + " Y" +point.y + " Z0" + " F1000"); // Write the coordinate to the file
      if (!posMoved) {
        output.println("M03 S"+pen_down);
        posMoved = true;
      }
    }
    output.println("M03 S "+pen_up);
    posMoved = false;
  }
  output.println("G0 X0 Y0 Z0 F1000");
  output.flush();
  output.close();
  println("SAVED");


}

void to_serial_output() {
  if (oked) {
    String display_text = "";
    if (gcodes != null) display_text = nf(float(forLoop)/float(gcodes.length-1)*100, 0, 4) + '%'+ ' '+ ':'+gcodes[forLoop];
    println(display_text);
    myPort.write(gcodes[forLoop]+'\n');
    oked=false;
  }
}

void serialEvent(Serial p) {
  if (p.available()>0) {
    String myString = p.readStringUntil('\n');
    if (myString != null) {
      myString = trim(myString);
      println(myString);
      if (serial_out) {
        if ((myString.equals("ok") || myString.equals("OK")) && forLoop <= gcodes.length) {
          oked = true;
          forLoop++;
          to_serial_output();
        }
      }
    }
  }
}