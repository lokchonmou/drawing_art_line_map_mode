void keyPressed() {
  if (key == ' ') {
    if (counter<3) {
      counter+=1;
    } else {
      counter=0;
    }
    println(counter);
  }

  if (selecting && key == '1') {
    println("Live Mode");
    working_mode = 1;
    selecting = false;
  }
  if (selecting && key == '2') {
    println("Photo Mode");
    working_mode = 2;
    selecting = false;
  }

  if (selecting && key == '3') {
    println("machine setting");
    working_mode = 3;
    selecting = false;
    selected = true;
  }

  if (keyCode == ENTER && working_mode == 3) setup();

  if (keyCode == ENTER && counter ==3) {
    save("OUTPUT.png");
    output.println("G90");
    output.println("$120=1000");
    output.println("$121=1000");
    output.println("M03 S"+pen_up);

    output.println("$30=255");
    output.println("$32=0");
    output.println("$31=0");
    output.println("$100=78.740");
    output.println("$101=78.740");
    output.println("$102=78.740");
    output.println("$110=8000.000");
    output.println("$111=8000.000");
    output.println("$112=3000.000");
    output.println("$120=500.000");
    output.println("$121=500.000");

    // output.println("G28");

    draw_shadow();
    printer_output();
    gcodes = loadStrings("positions.txt");
    image(loadImage("OUTPUT.png"), 0, 0, width, height);
    myPort.write("M03 S"+pen_up +'\n');
    serial_out=true;
  }

  if (keyCode == ESC) {
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
    exit();
  }
}


void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    path = selection.getAbsolutePath();
    println("User selected " + path);
    src = loadImage(path);
    _scale = float(src.height)/float(src.width); 
    frame.setSize(975, int(975*_scale));
    src.resize(width, height);
    opencv = new OpenCV(this, src);
    selected = true;
  }
}

void serial_select() {
  try {
    if (debug) printArray(Serial.list());
    int i = Serial.list().length;
    if (i != 0) {
      if (i >= 2) {
        // need to check which port the inst uses -
        // for now we'll just let the user decide
        for (int j = 0; j < i; ) {
          COMlist += char(j+'0') + " = " + Serial.list()[j];
          if (++j < i) COMlist += ",  ";
        }
        COMx = showInputDialog("Which COM port is correct? (0,1,..):\n"+COMlist);
        if (COMx == null) exit();
        if (COMx.isEmpty()) exit();
        i = int(COMx.toLowerCase().charAt(0) - '0') + 1;
      }
      String portName = Serial.list()[i-1];
      if (debug) println(portName);
      myPort = new Serial(this, portName, 115200); // change baud rate to your liking
      myPort.bufferUntil('\n'); // buffer until CR/LF appears, but not required..
    } else {
      showMessageDialog(frame, "Device is not connected to the PC");
      exit();
    }
  }
  catch (Exception e)
  { //Print the type of error
    showMessageDialog(frame, "COM port is not available (may\nbe in use by another program)");
    println("Error:", e);
    exit();
  }
}