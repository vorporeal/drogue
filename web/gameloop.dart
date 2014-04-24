import 'fps.dart';

import 'dart:async';
import 'dart:html' show window;

class GameLoop {
  final FPS fps = new FPS();
  final StreamController<double> _onTickController = new StreamController();
  Stream _onTick;

  double _timeOfLastFrame = 0.0;

  GameLoop() {
    _onTick = _onTickController.stream.asBroadcastStream();

    // Make sure that each tick requests another call to tick.
    onTick.listen((_) => window.animationFrame.then(_tick));
  }

  Stream<double> get onTick => _onTick;

  void _tick(double timeOfCurrentFrame) {
    var deltaT = timeOfCurrentFrame - _timeOfLastFrame;
    _timeOfLastFrame = timeOfCurrentFrame;

    // Add the elapsed time since last frame to the onTick stream.
    _onTickController.add(deltaT);
  }

  void start() {
    window.animationFrame.then((time) => _timeOfLastFrame = time).then(_tick);
  }
}