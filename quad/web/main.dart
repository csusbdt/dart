library main;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:web_gl' as GL;
import 'package:vector_math/vector_math.dart';
import 'scene.dart' as scene;

final Vector4 white = new Vector4(1.0, 1.0, 1.0, 1.0);

GL.RenderingContext gl;
int canvasWidth;
int canvasHeight;
double fov = 90.0;

Matrix4 viewMatrix = new Matrix4.identity();
Matrix4 projectionMatrix = null;

void main() {
  CanvasElement canvas = querySelector("#canvas");
  gl = canvas.getContext("webgl");
  if (gl == null) gl = canvas.getContext("experimental-webgl");
  assert (gl != null);
  
  window.onResize.listen(onResize);  
  window.requestAnimationFrame(render);

  Matrix4 cameraMatrix = new Matrix4.identity().translate(0.0, 0.0, 0.2);
  cameraMatrix.copyInverse(viewMatrix);
  
  gl.clearColor(0, 0, 0, 1);
  gl.enable(GL.BLEND);
  gl.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);

  onResize(null);
  
  scene.start();
}

void onResize(e) {
  CanvasElement canvas = querySelector("#canvas");
  canvasWidth = canvas.width = window.innerWidth;
  canvasHeight = canvas.height = window.innerHeight;
  gl.viewport(0, 0, canvasWidth, canvasHeight);
  projectionMatrix = makePerspectiveMatrix(fov * Math.PI / 180.0, canvas.width/canvas.height, 0.01, 100.0);
}

void render(double time) {
  gl.clear(GL.COLOR_BUFFER_BIT);
  scene.render(time);
  window.requestAnimationFrame(render);
}

double get volume {
  double max = double.parse((querySelector('#volume') as RangeInputElement).max);
  double value = (querySelector('#volume') as RangeInputElement).valueAsNumber;
  return value / max;
}
