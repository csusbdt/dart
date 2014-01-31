library main;

import 'dart:html';
import 'dart:web_gl' as GL;
import 'dart:math' as Math;
import 'package:vector_math/vector_math.dart';
import 'global.dart';
import 'billboard.dart' as billboard;
import 'texture.dart';

Texture texture;

void main() {
  CanvasElement canvas = querySelector("#canvas");
  gl = canvas.getContext("webgl");
  if (gl == null) gl = canvas.getContext("experimental-webgl");
  assert (gl != null);
  billboard.init();
  gl.clearColor(0, 0, 0, 1);
  
  texture = new Texture("textures/sheet.png");
  
  onResize(null);
  window.onResize.listen(onResize);  
  window.requestAnimationFrame(render);
}

void onResize(e) {
  CanvasElement canvas = querySelector("#canvas");
  canvasWidth = canvas.width = window.innerWidth;
  canvasHeight = canvas.height = window.innerHeight;
  gl.viewport(0, 0, canvasWidth, canvasHeight);
  double fov = 90.0;
  projectionMatrix = makePerspectiveMatrix(fov * Math.PI / 180.0, canvas.width/canvas.height, 0.01, 100.0);
}

void render(double time) {
  gl.clear(GL.COLOR_BUFFER_BIT);
  billboard.render(texture, new Vector3(-0.5, -0.5, -2.0), 0, 0, 32, 32, white);
  
  window.requestAnimationFrame(render);
}
