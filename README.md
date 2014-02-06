GaugeMon
========
<p>
Analog gauge monitor/logger/alarm using Android smart-phone and [IpWebcam] app.<p>

Coded using [Processing].<br>
It's really quick and messy code for automatic reading and logging of analog temperature meter, with alarm function. I don't have any plans to expand it. Setup example and screen shot are placed in */jpg* folder.

Usage
-----
<p>
- Install [app] [1] and use it in landscape mode. Place smart-phone in front of a gauge.
- Take note of IP address and enter it in code:
```
String IP = "http://your_ip_here:8080/";
```
- If your gauge has white background change this line to TRUE:
```
white = false;
```
- When program starts you have to calibrate it to run properly.

Calibration
-----------
Press 's' to enter setup mode. In setup mode you can adjust picture contrast using arrow keys (up/down - contrast, left/right - middle point). When adjusting contrast try to make gauge needle distinguishable from background. Then press 'm' to calibrate gauge. After pressing 'm' you should click on needle origin, then drag mouse to set up unity circle (the arc in which needle will be looked for, try to select line where only needle is crossed). Then just pick alarm point, 40 and 60 degree marks (you can setup your own of course) and press 's' again to exit setup mode. After this, whenever the temperature needle goes over alarm point - the program will beep. Checking is done every 30s.

Controls
---------
- s - enter/exit setup
- m - when in setup enter gauge calibration
- w - write contrast setup to file
- r - read contrast setup from file
- c - reset contrast setup
- arrow keys - setup picture contrast
- g - in normal mode (after calibration) read gauge immediately

[IpWebcam]:https://play.google.com/store/apps/details?id=com.pas.webcam&hl=en
[1]:https://play.google.com/store/apps/details?id=com.pas.webcam&hl=en
[Processing]:http://processing.org/