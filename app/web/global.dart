library global;

import 'dart:web_gl' as GL;
import 'package:vector_math/vector_math.dart';

GL.RenderingContext gl;
int canvasWidth;
int canvasHeight;

Matrix4 projectionMatrix = null;
Matrix4 viewMatrix = new Matrix4.identity().translate(0.0, 0.0, 1.0);

Vector4 white = new Vector4(1.0, 1.0, 1.0, 1.0);
