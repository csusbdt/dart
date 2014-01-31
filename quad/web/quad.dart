library quad;

import 'dart:web_gl' as GL;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'main.dart';

int posLocation;
GL.UniformLocation worldTransformLocation;
GL.UniformLocation viewTransformLocation;
GL.UniformLocation projectionTransformLocation;
GL.UniformLocation colorLocation;

void render(double time, Matrix4 worldMatrix, Vector4 color) {
  gl.uniformMatrix4fv(viewTransformLocation, false, viewMatrix.storage);
  gl.uniformMatrix4fv(projectionTransformLocation, false, projectionMatrix.storage);
  gl.uniformMatrix4fv(worldTransformLocation, false, worldMatrix.storage);
  gl.uniform4fv(colorLocation, color.storage);
  gl.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0);
}

void init() {
  if (posLocation != null) return;  // Already initialized.
  
  GL.Shader vertexShader = gl.createShader(GL.VERTEX_SHADER);
  gl.shaderSource(vertexShader, vertexShaderCode);
  gl.compileShader(vertexShader);
  if (!gl.getShaderParameter(vertexShader, GL.COMPILE_STATUS)) {
    throw gl.getShaderInfoLog(vertexShader);
  }
  
  GL.Shader fragmentShader = gl.createShader(GL.FRAGMENT_SHADER);
  gl.shaderSource(fragmentShader, fragmentShaderCode);
  gl.compileShader(fragmentShader);
  if (!gl.getShaderParameter(fragmentShader, GL.COMPILE_STATUS)) {
    throw gl.getShaderInfoLog(fragmentShader);
  }
  
  GL.Program program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, GL.LINK_STATUS)) {
    throw gl.getProgramInfoLog(program);
  }
  
  posLocation                 = gl.getAttribLocation (program, "a_pos");
  worldTransformLocation      = gl.getUniformLocation(program, "u_worldTransform");
  viewTransformLocation       = gl.getUniformLocation(program, "u_viewTransform");
  projectionTransformLocation = gl.getUniformLocation(program, "u_projectionTransform");
  colorLocation               = gl.getUniformLocation(program, "u_color");
  
  Float32List vertexArray = new Float32List(4 * 3);
  vertexArray.setAll(0 * 3, [0.0, 0.0, 0.0]);
  vertexArray.setAll(1 * 3, [0.0, 1.0, 0.0]);
  vertexArray.setAll(2 * 3, [1.0, 1.0, 0.0]);
  vertexArray.setAll(3 * 3, [1.0, 0.0, 0.0]);
  
  Int16List indexArray = new Int16List(2 * 3);
  indexArray.setAll(0, [0, 1, 2, 0, 2, 3]);

  gl.useProgram(program);
  gl.enableVertexAttribArray(posLocation);
  
  GL.Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(GL.ARRAY_BUFFER, vertexArray, GL.STATIC_DRAW);
  gl.vertexAttribPointer(posLocation, 3, GL.FLOAT, false, 0, 0);
  
  GL.Buffer indexBuffer = gl.createBuffer();
  gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
  gl.bufferDataTyped(GL.ELEMENT_ARRAY_BUFFER, indexArray, GL.STATIC_DRAW);
}

String vertexShaderCode = 
"""
  precision highp float;

  attribute vec3 a_pos;

  uniform mat4 u_worldTransform;
  uniform mat4 u_viewTransform;
  uniform mat4 u_projectionTransform;

  void main() {
    gl_Position = u_projectionTransform * u_viewTransform * u_worldTransform * vec4(a_pos, 1.0);
  }
""";

String fragmentShaderCode = 
"""
  precision highp float;

  uniform vec4 u_color;

  void main() {
    if (u_color.a > 0.0) {
      gl_FragColor = u_color;
    } else {
      discard;
    }
  }
""";
