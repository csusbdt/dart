library notch;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:web_gl' as GL;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

part 'shader.dart';

GL.RenderingContext gl;

class Quad {
  Shader shader;
  int posLocation;
  GL.UniformLocation objectTransformLocation;
  GL.UniformLocation cameraTransformLocation;
  GL.UniformLocation viewTransformLocation;
  GL.UniformLocation colorLocation;
  
  Quad(this.shader) {
    posLocation = gl.getAttribLocation(shader.program, "a_pos");
    objectTransformLocation = gl.getUniformLocation(shader.program, "u_objectTransform");
    cameraTransformLocation = gl.getUniformLocation(shader.program, "u_cameraTransform");
    viewTransformLocation = gl.getUniformLocation(shader.program, "u_viewTransform");
    colorLocation = gl.getUniformLocation(shader.program, "u_color");

    Float32List vertexArray = new Float32List(4 * 3);
    vertexArray.insertAll(0 * 3, [0, 0, 0]);
    vertexArray.insertAll(1 * 3, [1, 0, 0]);
    vertexArray.insertAll(2 * 3, [1, 1, 0]);
    vertexArray.insertAll(3 * 3, [0, 1, 0]);
    Int16List indexArray = new Int16List(2 * 3);
    indexArray.insertAll(0, [0, 1, 2, 0, 2, 3]);
    
    GL.Buffer vertexBuffer = gl.createBuffer();
    gl.useProgram(shader.program);
    gl.enableVertexAttribArray(posLocation);
    gl.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
    gl.bufferDataTyped(GL.ARRAY_BUFFER, vertexArray, GL.STATIC_DRAW);
    gl.vertexAttribPointer(posLocation, 3, GL.FLOAT, false, 0, 0);
  }
  
  void render(int x, int y, int w, int h, int uo, int vo) {
    
  }
}

class Game {
  CanvasElement canvas;
  Math.Random random;
  
  void start() {
    random = new Math.Random();
    canvas = querySelector("#game_canvas");
    gl = canvas.getContext("webgl");
    if (gl == null) {
      gl = canvas.getContext("experimental-webgl");
    }
    if (gl != null) {
      window.requestAnimationFrame(render);
    }
  }
  
  void render(double time) {
    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.clearColor(random.nextDouble(), random.nextDouble(), random.nextDouble(), 1.0);
    gl.clear(GL.COLOR_BUFFER_BIT);
    window.requestAnimationFrame(render);
  }
}

/*
void reverseText(MouseEvent event) {
  var text = querySelector("#sample_text_id").text;
  var buffer = new StringBuffer();
  for (int i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
  }
  querySelector("#sample_text_id").text = buffer.toString();
}
*/

void main() {
  new Game().start();
  /*
  querySelector("#sample_text_id")
    ..text = "Click me!"
    ..onClick.listen(reverseText);
*/
}
