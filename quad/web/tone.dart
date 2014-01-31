library tone;

import 'dart:web_audio';

AudioContext ctx = new AudioContext();

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
    
  void start() {
    oscillator.start(0);
  }
  
  void stop() {
    oscillator.stop(0);
  }
}
