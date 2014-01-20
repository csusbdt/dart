import 'dart:html';
import 'dart:math' as Math;
import 'dart:web_gl' as WebGL;
import 'dart:typed_data';

class Game {
  CanvasElement canvas;
  WebGL.RenderingContext gl;
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
    gl.clear(WebGL.COLOR_BUFFER_BIT);
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
