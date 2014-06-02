part of core;

class GameLoop {
  final FPS fps = new FPS();
  final StreamController<double> _onTickController = new StreamController();
  Stream _onTick;

  double _lastFrameTimestampMs = 0.0;

  GameLoop() {
    _onTick = _onTickController.stream.asBroadcastStream();

    onTick
        // Make sure that each tick requests another call to tick.
        ..listen((_) => window.animationFrame.then(_tick))
        // Update the FPS counter each frame.
        ..listen((deltaT) => fps.update(deltaT));
  }

  Stream<double> get onTick => _onTick;

  void _tick(double currentFrameTimestampMs) {
    var deltaT = (currentFrameTimestampMs - _lastFrameTimestampMs) * 0.001;
    _lastFrameTimestampMs = currentFrameTimestampMs;

    // Add the elapsed time since last frame to the onTick stream.
    _onTickController.add(deltaT);
  }

  void start() {
    window.animationFrame
        .then((time) => _lastFrameTimestampMs = time)
        .then(_tick);
  }
}