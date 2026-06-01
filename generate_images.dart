import 'dart:io';
import 'package:image/image.dart';

void main() {
  // Create 1024x1024 black background with V
  var icon = Image(width: 1024, height: 1024);
  fill(icon, color: ColorRgb8(10, 10, 10)); 
  drawString(icon, 'V', font: arial48, x: 500, y: 500, color: ColorRgb8(255, 255, 255));
  File('assets/icon/app_icon.png').writeAsBytesSync(encodePng(icon));

  // Create 1024x1024 transparent foreground
  var fg = Image(width: 1024, height: 1024);
  drawString(fg, 'V', font: arial48, x: 500, y: 500, color: ColorRgb8(255, 255, 255));
  File('assets/icon/app_icon_foreground.png').writeAsBytesSync(encodePng(fg));

  var splash = Image(width: 300, height: 300);
  drawString(splash, 'Vesto', font: arial48, x: 100, y: 120, color: ColorRgb8(255, 255, 255));
  File('assets/icon/splash_logo.png').writeAsBytesSync(encodePng(splash));
  
  print("Images generated successfully.");
}
