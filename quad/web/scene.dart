library scene;

import 'box_song.dart' as song;
import 'package:vector_math/vector_math.dart';

Matrix4 transform = new Matrix4.identity().scale(1.0, 1.0, 1.0).translate(0.0, 0.0, -4.0);

void start() {
  song.start();
}

void stop() {
  song.stop();
}

void render(double time) {
  song.render(time, transform);
}

