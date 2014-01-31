library song;

import 'dart:math' as math;
import 'tone.dart';
import 'quad.dart' as quad;
import 'package:vector_math/vector_math.dart';

var random = new math.Random();

Tone toneA = new Tone()..gain = 0.6;
var transitionTimeA = 0.0;
var minFrequencyA = 250.0;
var maxFrequencyA = 270.0;
var minColorA = new Vector4(0.5, 0.0, 0.0, 0.5);
var maxColorA = new Vector4(1.0, 0.0, 0.0, 0.5);
Vector4 colorA = new Vector4(0.5, 0.0, 0.0, 0.5);

Tone toneB = new Tone()..gain = 0.8;
var transitionTimeB = 0.0;
var minFrequencyB = 195.0;
var maxFrequencyB = 245.0;
var minColorB = new Vector4(0.0, 0.5, 0.0, 0.5);
var maxColorB = new Vector4(0.0, 1.0, 0.0, 0.5);
Vector4 colorB;

Tone toneC = new Tone()..gain = 1.0;
var transitionTimeC = 0.0;
var minFrequencyC = 140.0;
var maxFrequencyC = 175.0;
var minColorC = new Vector4(0.0, 0.0, 0.5, 0.5);
var maxColorC = new Vector4(0.0, 0.0, 1.0, 0.5);
Vector4 colorC;

//Matrix4 transformA = new Matrix4.identity().scale(1.0, 1.0, 1.0).translate(0.0, 0.0, 0.0);
//Matrix4 transformB = new Matrix4.identity().scale(1.0, 2.0, 1.0).translate(0.0, -1.0, 0.0);
//Matrix4 transformC = new Matrix4.identity().scale(1.0, 3.0, 1.0).translate(1.0, -0.6667, 0.0);

Matrix4 transformA = new Matrix4.identity().translate(-1.0,  1.0, 0.1);//.scale(2.0, 2.0, 1.0);
Matrix4 transformB = new Matrix4.identity().translate( 0.0,  0.0, 0.2);//.scale(2.0, 2.0, 1.0);
Matrix4 transformC = new Matrix4.identity().translate( 1.0, -1.0, 0.3);//.scale(2.0, 2.0, 1.0);

void start() {
  quad.init();
  transitionTimeA = 0.0;
  toneA.frequency = 0.0;
  toneA.start();
  transitionTimeB = 0.0;
  toneB.frequency = 0.0;
  toneB.start();
  transitionTimeC = 0.0;
  toneC.frequency = 0.0;
  toneC.start();
}

void stop() {
  toneA.stop();
  recycleTone(toneA);
  toneA = null;
  toneB.stop();
  recycleTone(toneB);
  toneB = null;
  toneC.stop();
  recycleTone(toneC);
  toneC = null;
}

void render(double time, Matrix4 transform) {
  if (time > transitionTimeA) {
    var p = random.nextDouble();
    transitionTimeA = time + p * 2000.0;
    colorA = minColorA * p + maxColorA * (1.0 - p);
    toneA.frequency = minFrequencyA * p + maxFrequencyA * (1.0 - p);
  }
  if (time > transitionTimeB) {
    var p = random.nextDouble();
    transitionTimeB = time + p * 5000.0;
    colorB = minColorB * p + maxColorB * (1.0 - p);
    toneB.frequency = minFrequencyB * p + maxFrequencyB * (1.0 - p);
  }
  if (time > transitionTimeC) {
    var p = random.nextDouble();
    transitionTimeC = time + p * 10000.0;
    colorC = minColorC * p + maxColorC * (1.0 - p);
    toneC.frequency = minFrequencyC * p + maxFrequencyC * (1.0 - p);
  }
  quad.render(time, transform * transformA, colorA);
  quad.render(time, transform * transformB, colorB);
  quad.render(time, transform * transformC, colorC);
}
