part of core;

class FPS {
  int _windowSize;
  Queue<double> _frameTimes;
  double _sum = 0.0;
  double _averageFrameTime = 0.0;

  FPS({int windowSize: 60}) {
    _windowSize = windowSize;
    _frameTimes = new ListQueue(windowSize);
  }

  String update(double frameTime) {
    _frameTimes.add(frameTime);
    _sum += frameTime;

    if (_frameTimes.length > _windowSize) {
      _sum -= _frameTimes.removeFirst();
    }

    _averageFrameTime = _sum / _frameTimes.length;

    return this.toString();
  }

  String toString() {
    assert(_frameTimes.length <= _windowSize);
    if (_frameTimes.length < _windowSize) {
      return "??";
    }

    return (1 / _averageFrameTime).round().toString();
  }
}