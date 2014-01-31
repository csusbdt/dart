library texture;

import 'dart:html';
import 'dart:web_gl' as GL;
import 'global.dart';

class Texture {
  String url;
  GL.Texture texture;
  int width;
  int height;
  bool loaded = false;
  
  Texture(this.url) {
    ImageElement img = new ImageElement();
    img.src = url;
    img.onLoad.listen((e) {
      texture = gl.createTexture();
      gl.bindTexture(GL.TEXTURE_2D, texture);
      gl.texImage2DImage(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, img);
      gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
      gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
      width = img.width;
      height = img.height;
      loaded = true;
    });
  }
}
