library notch;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:web_gl' as GL;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

part 'shader.dart';

GL.RenderingContext gl;

class Texture {
  static List<Texture> _unloadedTextures = new List<Texture>();
  
  static void loadAll() {
    _unloadedTextures.forEach((e) => e._load());
    _unloadedTextures.clear();
  }
  
  String url;
  GL.Texture texture;
  int width;
  int height;
  bool loaded = false;
  
  Texture(this.url) {
    if (gl == null) {
      _unloadedTextures.add(this);
    } else {
      _load();
    }
  }
  
  void _load() {
    ImageElement img = new ImageElement();
    texture = gl.createTexture();
    img.onLoad.listen((e) {
      gl.bindTexture(GL.TEXTURE_2D, texture);
      gl.texImage2DImage(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, img);
      gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
      gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
      width = img.width;
      height = img.height;
      loaded = true;
    });
    img.src = url;
  }
}

class Quad {
  Texture texture;
  Shader shader;
  int posLocation;  
  Matrix4 objectMatrix = new Matrix4.identity();
  Matrix4 textureMatrix = new Matrix4.identity();

  GL.UniformLocation objectTransformLocation;
  GL.UniformLocation cameraTransformLocation;
  GL.UniformLocation viewTransformLocation;
  GL.UniformLocation textureTransformLocation;
  GL.UniformLocation colorLocation;
  
  Quad(this.shader) {
    posLocation              = gl.getAttribLocation(shader.program, "a_pos");
    objectTransformLocation  = gl.getUniformLocation(shader.program, "u_objectTransform");
    cameraTransformLocation  = gl.getUniformLocation(shader.program, "u_cameraTransform");
    viewTransformLocation    = gl.getUniformLocation(shader.program, "u_viewTransform");
    textureTransformLocation = gl.getUniformLocation(shader.program, "u_textureTransform");
    colorLocation =            gl.getUniformLocation(shader.program, "u_color");

    Float32List vertexArray = new Float32List(4 * 3);
    vertexArray.setAll(0 * 3, [0.0, 0.0, 0.0]);
    vertexArray.setAll(1 * 3, [0.0, 1.0, 0.0]);
    vertexArray.setAll(2 * 3, [1.0, 1.0, 0.0]);
    vertexArray.setAll(3 * 3, [1.0, 0.0, 0.0]);
    
    Int16List indexArray = new Int16List(2 * 3);
    indexArray.setAll(0, [0, 1, 2, 0, 2, 3]);

    gl.useProgram(shader.program);
    gl.enableVertexAttribArray(posLocation);
    
    GL.Buffer vertexBuffer = gl.createBuffer();
    gl.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
    gl.bufferDataTyped(GL.ARRAY_BUFFER, vertexArray, GL.STATIC_DRAW);
    gl.vertexAttribPointer(posLocation, 3, GL.FLOAT, false, 0, 0);
    
    GL.Buffer indexBuffer = gl.createBuffer();
    gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferDataTyped(GL.ELEMENT_ARRAY_BUFFER, indexArray, GL.STATIC_DRAW);
  }
  
  void setTexture(Texture texture) {
    this.texture = texture;
    gl.bindTexture(GL.TEXTURE_2D, texture.texture);
  }
  
  void setCamera(Matrix4 viewMatrix, Matrix4 cameraMatrix) {
    gl.uniformMatrix4fv(viewTransformLocation, false, viewMatrix.storage);
    gl.uniformMatrix4fv(cameraTransformLocation, false, cameraMatrix.storage);
  }
  
  void renderBillboard(Vector3 pos, int w, int h, int uo, int vo, Vector4 color) {
    if (!texture.loaded) return;

    objectMatrix.setIdentity();
    objectMatrix.translate(pos.x - w/2.0, pos.y - h * 1.0, pos.z);
    objectMatrix.scale(w * 1.0, h * 1.0, 0.0);
    gl.uniformMatrix4fv(objectTransformLocation, false, objectMatrix.storage);

    textureMatrix.setIdentity();
    textureMatrix.scale(1.0/texture.width, 1.0/texture.height, 0.0);
    textureMatrix.translate((uo + 0.25), (vo + 0.25), 0.0);
    textureMatrix.scale((w - 0.5), (h - 0.5), 0.0);    
    gl.uniformMatrix4fv(textureTransformLocation, false, textureMatrix.storage);

    gl.uniform4fv(colorLocation, color.storage);
    gl.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0);
  }

  void render(Vector3 pos, int w, int h, int uo, int vo, Vector4 color) {
    if (!texture.loaded) return;
  
    objectMatrix.setIdentity();
    objectMatrix.translate(pos.x, pos.y, pos.z);
    objectMatrix.scale(w * 1.0, h * 1.0, 0.0);
    gl.uniformMatrix4fv(objectTransformLocation, false, objectMatrix.storage);
  
    textureMatrix.setIdentity();
    textureMatrix.scale(1.0/texture.width, 1.0/texture.height, 0.0);
    textureMatrix.translate(uo * 1.0, vo * 1.0, 0.0);
    textureMatrix.scale(w * 1.0, h * 1.0, 0.0);    
    gl.uniformMatrix4fv(textureTransformLocation, false, textureMatrix.storage);
  
    gl.uniform4fv(colorLocation, color.storage);
    gl.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0);
  }
}

class Game {
  CanvasElement canvas;
  Quad quad;
  Texture sheetTexture = new Texture("tex/sheet.png");  
  Texture groundTexture = new Texture("tex/ground.png");  
  double fov = 90.0;
  
  void start() {
    canvas = querySelector("#game_canvas");
    gl = canvas.getContext("webgl");
    if (gl == null) {
      gl = canvas.getContext("experimental-webgl");
    }
    quad = new Quad(quadShader);
    Texture.loadAll();
    if (gl != null) {
      window.requestAnimationFrame(render);
    }
    
    gl.enable(GL.DEPTH_TEST);
    gl.depthFunc(GL.LESS);
  }
  
  void render(double time) {
    double pixelScale = 2.0;
    
    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(GL.COLOR_BUFFER_BIT);
    
    Matrix4 viewMatrix = makePerspectiveMatrix(fov * Math.PI / 180.0, canvas.width/canvas.height, 0.01, 100.0);
    double scale = pixelScale * 2.0 / canvas.height;
    Matrix4 screenMatrix = new Matrix4.identity().scale(scale, -scale, scale);
    double rot = new DateTime.now().millisecondsSinceEpoch % 4000 / 4000.0 * Math.PI * 2.0;
    Matrix4 cameraMatrix = new Matrix4.identity().translate(0.0, 8.0, -50.0).rotateY(rot);
    Matrix4 floorCameraMatrix = new Matrix4.identity().translate(0.0, 32.0, -50.0).rotateX(Math.PI / 2.0);

    Vector4 whiteColor = new Vector4(1.0, 1.0, 1.0, 1.0);

    quad.setCamera(viewMatrix, screenMatrix * cameraMatrix * floorCameraMatrix);
    quad.setTexture(groundTexture);
    quad.render(new Vector3(0.0, 0.0, 0.0), 256, 256, 0, 0, whiteColor);
    
    quad.setCamera(viewMatrix, screenMatrix);
    quad.setTexture(sheetTexture);    
    quad.renderBillboard(cameraMatrix * new Vector3(-30.0, 0.0, 0.0), 24, 95, 0, 0, whiteColor);
    
    window.requestAnimationFrame(render);
  }
}

void main() {
  new Game().start();
}
