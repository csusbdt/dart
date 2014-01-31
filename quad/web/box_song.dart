library box_song;

import 'dart:math' as math;
import 'tone.dart';
import 'quad.dart' as quad;
import 'package:vector_math/vector_math.dart';

var random = new math.Random();

class Note {
  double averageDuration;
  double transitionTime;
  double minFrequency;
  double maxFrequency;
  Tone tone;
  Vector4 minColor;
  Vector4 maxColor;  
  Vector4 color;
  Matrix4 transform;
  
  Note() : transitionTime = 0.0,
           minFrequency = 140.0, 
           maxFrequency = 240.0,
           tone = new Tone(),
           minColor = new Vector4(0.0, 0.0, 0.0, 1.0),
           maxColor = new Vector4(1.0, 1.0, 1.0, 1.0),
           transform = new Matrix4.identity();
  
  void randomize(double time) {
    var p = random.nextDouble();
    color = minColor * p + maxColor * (1.0 - p);
    tone.frequency = minFrequency * p + maxFrequency * (1.0 - p);    
    transitionTime = time + p * averageDuration;
  }
  
  void start() {
    tone.frequency = 0.0;
    tone.start();
    transitionTime = 0.0;
  }
  
  void stop() {
    tone.stop();
  }
  
  void render(double time, Matrix4 parentTransform) {
    if (time >= transitionTime) {
      var p = random.nextDouble();
      transitionTime = time + p * averageDuration;
      color = minColor * p + maxColor * (1.0 - p);
      tone.frequency = minFrequency * p + maxFrequency * (1.0 - p);
    }
    quad.render(time, parentTransform * transform, color);
  }
}
 
Note noteB = new Note()
    ..minColor = new Vector4(0.0, 0.0, 0.5, 0.5)
    ..maxColor = new Vector4(0.0, 0.0, 1.0, 0.5)
    ..minFrequency = 195.0
    ..maxFrequency = 245.0
    ..minFrequency = 120.0
    ..maxFrequency = 195.0
    ..averageDuration = 2000.0
    ..tone.gain = 0.8
    ..transform = new Matrix4.identity().translate(0.0, 0.0, 0.2);

Note noteC = new Note()
    ..minColor = new Vector4(0.0, 0.2, 0.0, 0.5)
    ..maxColor = new Vector4(0.0, 0.6, 0.0, 0.5)
    ..minFrequency = 215.0
    ..maxFrequency = 255.0
    ..averageDuration = 5000.0
    ..tone.gain = 0.2;

Matrix4 cStartTransform = new Matrix4.identity().translate(1.0, -1.0, 0.1);
Matrix4 cEndTransform = new Matrix4.identity().translate(-1.0, -1.0, 0.1);

double minMinFrequencyB = 100.0;
double maxMinFrequencyB = 140.0;
double minMaxFrequencyB = 150.0;
double maxMaxFrequencyB = 180.0;

double minMinFrequencyC = 200.0;
double maxMinFrequencyC = 220.0;
double minMaxFrequencyC = 230.0;
double maxMaxFrequencyC = 240.0;

double minAverageDurationB =  600.0;
double maxAverageDurationB = 1500.0;

double minAverageDurationC = 1500.0;
double maxAverageDurationC = 4000.0;

double randomOffset1;
double randomOffset2;
double randomOffset3;
double randomOffset4;

void start() {
  randomOffset1 = random.nextDouble();
  randomOffset2 = random.nextDouble();
  randomOffset3 = random.nextDouble();
  randomOffset4 = random.nextDouble();
  quad.init();
  cStartTransform.copyInto(noteC.transform);
  noteB.start();
  noteC.start();
}

void stop() {
  noteB.stop();
  noteC.stop();
}

void render(double time, Matrix4 transform) {
  double p = 0.5 * (1 + math.sin(time / 2000.0));
  (cEndTransform * (1 - p) + cStartTransform * p).copyInto(noteC.transform);
    
  double pB = 0.5 * (1 + math.sin(randomOffset1 * math.PI * 2 + time / 1000.0 * math.PI * 2.0 / 60));
  noteB.minFrequency = minMinFrequencyB * (1 - pB) + maxMinFrequencyB * pB;  
  noteB.maxFrequency = minMaxFrequencyB * (1 - pB) + maxMaxFrequencyB * (pB);  
  
  double pC = 0.5 * (1 + math.sin(randomOffset2 * math.PI * 2 + time / 1000.0 * math.PI * 2.0 / 70));
  noteC.minFrequency = minMinFrequencyC * (1 - pC) + maxMinFrequencyC * pC;  
  noteC.maxFrequency = minMaxFrequencyC * (1 - pC) + maxMaxFrequencyC * (pC);  

  p = 0.5 * (1 + math.sin(randomOffset3 * math.PI * 2 + time / 1000.0 * math.PI * 2.0 / 50));
  noteB.averageDuration = minAverageDurationB * (1 - p) + maxAverageDurationB * p;

  p = 0.5 * (1 + math.sin(randomOffset4 * math.PI * 2 + time / 1000.0 * math.PI * 2.0 / 40));
  noteC.averageDuration = minAverageDurationC * (1 - p) + maxAverageDurationC * p;

  noteB.render(time, transform);
  noteC.render(time, transform);
}
