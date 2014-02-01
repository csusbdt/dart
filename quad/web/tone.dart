library tone;

import 'dart:web_audio';
import 'dart:html' as html;
import 'main.dart' as main;

AudioContext ctx = new AudioContext();

class Tone {
  OscillatorNode oscillator;
  GainNode gainNode;
  double _gain;
  
  Tone() {
    gainNode = ctx.createGainNode()
        ..connectNode(ctx.destination, 0, 0);    
    oscillator = ctx.createOscillator()
        ..type = "sine"
        ..frequency.value = 220
        ..connectNode(gainNode, 0, 0);
    _gain = 1.0;
    html.querySelector('#volume').onChange.listen((_) {
      gainNode.gain.value = _gain * main.volume;
    });    
  }
  
  void set gain(double value) {
    _gain = value;
    gainNode.gain.value = _gain * main.volume;
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
