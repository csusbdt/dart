library billboard;

import 'dart:web_gl' as GL;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'global.dart';
import 'texture.dart';

int posLocation;
GL.UniformLocation worldTransformLocation;
GL.UniformLocation viewTransformLocation;
GL.UniformLocation projectionTransformLocation;
GL.UniformLocation textureTransformLocation;
GL.UniformLocation colorLocation;

Matrix4 worldMatrix = new Matrix4.identity();
Matrix4 textureMatrix = new Matrix4.identity();

void render(Texture texture, Vector3 pos, int u, int v, int w, int h, Vector4 color) {
  if (!texture.loaded) return;

  gl.uniformMatrix4fv(viewTransformLocation, false, viewMatrix.storage);
  gl.uniformMatrix4fv(projectionTransformLocation, false, projectionMatrix.storage);
  
  worldMatrix.setIdentity().translate(pos);
  gl.uniformMatrix4fv(worldTransformLocation, false, worldMatrix.storage);

  textureMatrix.setIdentity();//.scale(1.0 / texture.width, 1.0 / texture.height, 0.0);
//  textureMatrix.translate(u, v, 0.0);
  //textureMatrix.scale((w - 0.5), (h - 0.5), 0.0);    
  //gl.uniformMatrix4fv(textureTransformLocation, false, textureMatrix.storage);

  gl.uniform4fv(colorLocation, color.storage);
  gl.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0);
}

void init() {
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
  
  posLocation                 = gl.getAttribLocation(program, "a_pos");
  worldTransformLocation      = gl.getUniformLocation(program, "u_worldTransform");
  viewTransformLocation       = gl.getUniformLocation(program, "u_viewTransform");
  projectionTransformLocation = gl.getUniformLocation(program, "u_projectionTransform");
  textureTransformLocation    = gl.getUniformLocation(program, "u_textureTransform");
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
  uniform mat4 u_textureTransform;

  varying vec2  v_texcoord;
  varying float v_dist;

  void main() {
    //v_texcoord = (u_textureTransform * vec4(a_pos, 1.0)).xy;
    //v_texcoord = vec2(xOffset + xScale * a_pos.x, yOffset + yScale * a_pos.y);
    float xOffset = 0.0;
    float yOffset = 0.0;
    v_texcoord = vec2(a_pos.x + xOffset, a_pos.y + yOffset);
    vec4 pos = u_projectionTransform * u_viewTransform * u_worldTransform * vec4(a_pos, 1.0);//
//    v_dist = pos.z;
    v_dist = 0.0;
    gl_Position = pos;
  }
""";

String fragmentShaderCode = 
"""
  precision highp float;

  uniform sampler2D u_tex;
  uniform vec4      u_color;

  varying vec2  v_texcoord;
  varying float v_dist;

  void main() {
    vec4 col = texture2D(u_tex, v_texcoord);
    if (col.a > 0.0) {
      gl_FragColor = vec4((col * u_color).xyz / (v_dist * 4.0 + 1.0), 1.0);
    } else {
      discard;
    }
//    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  }
""";

