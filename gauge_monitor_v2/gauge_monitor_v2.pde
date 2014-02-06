import java.awt.Toolkit;

PImage pImg;
PImage img;
//PGraphics img;
int cVal, cPt;
boolean stp, ms, gs, mo, mu, ma, m40, m60, white;
int xO, yO, xA, yA, x40, y40, x60, y60;
float To, Ta, deg, T, U; // - unity circle

int time;

// hardcoded ip address of IpWebcam enabled device. See readme for mor details abut app.
String  IP = "http://192.168.5.102:8080/";

PFont fnt;

PrintWriter tLog;

void setup(){
  String fname = "log_"+str(year())+"-"+str(month())+"-"+str(day())+"_"+str(minute())+".csv";
  tLog = createWriter(fname);
  
 size (800, 480);
 smooth();
 stroke(255);
 fill(255);
 
 fnt = createFont("Georgia", 20);
 textFont(fnt);
 
 stp = false; // Setup mode
 ms = false;  // Mouse mode
 gs = false;  // Gauge setup done
 mo = false;  // Pointing to origin
 mu = false;  // Pointing to unity circle
 ma = false;  // Setting alarm point
 m40 = false; // Calibrate 40 degree mark
 m60 = false; // Calibrate 60 degree mark
 
 cVal = 0;    // Contrast value
 cPt = 128;   // Contrast middle point
 
 white = false; // Gauge background is white, then must be true

 img = CAM();
 
 img.filter(GRAY);
 if (white) {img.filter(INVERT);}
 pImg = img.get();
 image(pImg, 0, 0);
 
 time = millis(); 
 
}

void draw(){
  // Drawing in setup mode
  if (ms){
    refresh(1);
    stroke(192, 64, 0);
    line(mouseX - 3, mouseY, mouseX + 3, mouseY);
    line(mouseX, mouseY - 3, mouseX, mouseY + 3);
    if (mu || ma || m40 || m60){
      // draw line from origin
      line (xO, yO, mouseX, mouseY);
      noFill();
      if (mu){
        // Draw unity circle
        strokeWeight(4);
        arc(xO, yO,2 * dist(xO, yO, mouseX, mouseY), 2 * dist(xO, yO, mouseX, mouseY), PI, TWO_PI);
        strokeWeight(1);
      }
      fill(255);
    }
    stroke(255);
  }
  
  // Trigger execution
  if (gs && (!stp)){
    if ((millis() - time) > 30000){
      img = CAM();
      img.filter(GRAY);
      if (white) {img.filter(INVERT);}
      pImg = img.get();
      refresh(0);
      gauge(pImg);
      time = millis();
    }
  }
}

void ledOn(){
  String lines[] = loadStrings(IP + "enabletorch");
  delay(5000); // Time for camera to adjust brightness
}

void ledOff(){
  String lines[] = loadStrings(IP + "disabletorch");
}

PImage CAM(){
  ledOn();
  PImage i;
  i = loadImage(IP + "shot.jpg");
  ledOff();
  return(i);
}

// line in radial coordinates. use 'g' for wnd argument to access main window
void aLine(PGraphics wnd, float xo, float yo, float a, float d){
  wnd.beginDraw();
  wnd.line(xo, yo, xo + d * cos(radians(a)), yo - d * sin(radians(a)));
  wnd.endDraw();
}

// Gauge reading routine
void gauge(PImage wnd){
  String sTime = str(hour()) + ":" + str(minute()) + ":" + str(second());
  float avg, ang;
  wnd.loadPixels();
  ang = 0;
  avg = 0;
  
  for (float i = 0; i < 180; i += 0.1){
    int xx = round(xO + U * cos(radians(i)));
    int yy = round(yO - U * sin(radians(i)));
    int cnt = 0;
    int sum = 0;
    for (int yyy = yy - 3; yyy < (yy + 3); yyy++){
      for (int xxx = xx - 3; xxx < (xx + 3); xxx++){
        sum = sum + (wnd.pixels[yyy * width + xxx] & 0xFF);
        cnt = cnt + 1;
      }
    }
    float a = float(sum)/float(cnt);
    if (avg < a) {
      avg = a;
      ang = i;
    }
  }
  
  g.stroke(0,255,0);
  g.strokeWeight(3);
  aLine(g, xO, yO, ang, 250);
  strokeWeight(1);
  g.stroke(255);
  
  T = 60 + (To - radians(ang)) / deg;
  int ta = round (60 + (To - Ta) / deg);
  if (T > ta) {alarm();}
  fill(255, 0, 0);
  text("T: " + str(round(T)), 10, 30);
  text("alarm: "+str(ta), 10, 50);
  text(sTime, 10, 470);
  fill(255);
  tLog.println(round(T)+";"+sTime);
  tLog.flush();
}

void alarm(){
  Toolkit.getDefaultToolkit().beep();
}

// Keep color value in range
int trunc(int t){
  return (min(max(t, 0), 255));
}

void calibrateT(){
  To = -atan2((y60 - yO), (x60 - xO));
  Ta = -atan2((yA - yO), (xA - xO));
  deg = abs(atan2((y60 - yO), (x60 - xO)) - atan2((y40 - yO), (x40 - xO))) / 20.0;
}

void contrast(){
  float F = (259.0 * (cVal + 255.0)) / (255.0 * (259.0 - cVal));
  pImg.loadPixels();
  for (int i = 0; i < pImg.pixels.length; i++){
    color t = pImg.pixels[i];
    int v = t & 0xFF;
    v = trunc(round(F * (v - cPt)) + cPt);
    pImg.pixels[i] = color(v, v, v);
  }
  pImg.updatePixels();
}

void refresh(int r){
  // skip contrast recalculation?
  if (r == 0) {
    pImg = img.get();
    contrast();
  }
  
  image(pImg, 0, 0);
  
  if (stp){
    if (!ms){
      fill(255,0 ,0);
      text("Contrast: " + str(cVal), 10, 450);
      text("Contrast middle point: " + str(cPt), 10, 430);
      text("Setup Contrast", 10,30);
      fill(255);
    }
  }
  
  if (ms){
    fill(255,0 ,0);
    text("Setup Gauge", 10, 30);
    if (mo) {text("Set Origin", 10, 50);}
    if (mu) {text("Set Unity", 10, 50);}
    if (ma) {text("Set Alarm", 10, 50);}
    if (m40) {text("Calibrate 40 degree mark", 10, 50);}
    if (m60) {text("Calibrate 60 degree mark", 10, 50);}
    fill(255);
  }
  
  // Draw some lines after setup is done
  if (gs){
    stroke(255, 0, 0);
    strokeWeight(3);
    line(xO, yO, xA, yA);
    strokeWeight(1);
    stroke(255);
  }
}

void keyPressed(){
  switch(key){
    case 'w':
      if (stp){
        String[] data = {str(cVal), str(cPt)};
        saveStrings("contrast.cfg", data); 
      }
      break;
    case 'r':
      if (stp){
        String data[] = loadStrings("contrast.cfg");
        cVal = int(data[0]);
        cPt = int(data[1]);
      }
      refresh(0);
      break;
    case 'g':
      if(gs){
        img = CAM();
        img.filter(GRAY);
        if(white) {img.filter(INVERT);}
        pImg = img.get();
        refresh(0);
        gauge(pImg);
      }
      break;
    case 'm':
      if (stp){
        ms = !ms;
        mo = stp && ms;
        mu = false;
        ma = false;
        refresh(0);
      }
      break;
    case 's':
      stp = !stp;
      if (!stp){
        ms = false;
      }
      refresh(0);
      break;
    case 'c':
      if (stp){
        cVal = 0;
        cPt = 128;
        ms = false;
        refresh(0);
      }
      break;
    case 'q':
      ledOff();
      tLog.flush();
      tLog.close();
      exit();
      break;
    default:
      break;
  }
  
  if (stp && (!ms)){
    switch(keyCode){
      case UP:
        cVal = cVal + 2;
        refresh(0);
        break;
      case DOWN:
        cVal = cVal - 2;
        refresh(0);
        break;
      case LEFT:
        cPt = cPt - 2;
        refresh(0);
        break;
      case RIGHT:
        cPt = cPt + 2;
        refresh(0);
        break;
      default:
        break;
    }
  }
}

void mouseClicked(){
  if(mo){
    xO = mouseX;
    yO = mouseY;
    mo = !mo;
    mu = !mu;
    refresh(1);
    return;
  }
  
  if(mu){
    U =abs(dist(xO, yO, mouseX, mouseY));
    mu = !mu;
    ma = !ma;
    refresh(1);
    return;
  }
  
  if(ma){
    xA = mouseX;
    yA = mouseY;
    ma = !ma;
    m40 = !m40;
    refresh(1);
    return;
  }
  
  if(m40){
    x40 = mouseX;
    y40 = mouseY;
    m40 = !m40;
    m60 = !m60;
    refresh(1);
    return;
  }
  
  if(m60){
    x60 = mouseX;
    y60 = mouseY;
    m60 = !m60;
    ms = !ms;
    gs = true;
    calibrateT();
    refresh(1);
    return;
  }
}

void stop(){
  
  super.stop();
}
