library tone;

import 'dart:web_audio';
import 'dart:async';

AudioContext ctx = new AudioContext();

var _tones = new Set<Tone>();

Tone getTone() {
  if (_tones.isEmpty) _tones.add(new Tone());
  Tone tone = _tones.first;
  _tones.remove(tone);
  return tone;
}

void recycleTone(Tone tone) {
  _tones.add(tone);
}

class Tone {
  OscillatorNode oscillator;
  GainNode gainNode;
  
  Tone() {
    gainNode = ctx.createGainNode()
        ..gain.value = 1.0
        ..connectNode(ctx.destination, 0, 0);    
    oscillator = ctx.createOscillator()
        ..type = "sine"
        ..frequency.value = 220
        ..connectNode(gainNode, 0, 0);
  }

  double get gain => gainNode.gain.value;
  
  void set gain(double value) {
    gainNode.gain.value = value;
  }
  
  double get frequency => oscillator.frequency.value;
  
  void set frequency(double value) {
    oscillator.frequency.value = value;
  }
  
  void play(int milliseconds) {
    start();
    var timer = new Timer(new Duration(milliseconds: milliseconds), () {
      stop();
    });
  }
  
  void start() {
    oscillator.start(0);
  }
  
  void stop() {
    oscillator.stop(0);
  }
}
