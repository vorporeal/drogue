library limiters;

import 'dart:async';

abstract class Limiter {
  Function _fn;
  StreamController _outputStreamController = new StreamController();

  Limiter.of(this._fn);

  bool _canExecute();

  Stream get outputStream => _outputStreamController.stream;

  noSuchMethod(Invocation args) {
    if (args.memberName != #call) {
      return super.noSuchMethod(args);
    }
    if (_canExecute()) {
      var out = Function.apply(_fn, args.positionalArguments, args.namedArguments);
      _outputStreamController.add(out);
    }
  }
}

class TotalLimiter extends Limiter {
  TotalLimiter.of(Function f) : super.of(f);

  @override
  bool _canExecute() {
    return false;
  }
}

class UnLimiter extends Limiter {
  UnLimiter.of(Function f) : super.of(f);

  @override
  bool _canExecute() {
    return true;
  }
}

typedef bool Precondition();

class RateLimiter extends Limiter {
  Precondition precondition = () => true;
  double _periodSecs = double.INFINITY;
  double _secsSinceLastExecute = 0.0;

  RateLimiter.of(Function f) : super.of(f);

  set frequency(double freq) {
    if (freq == 0.0) {
      _periodSecs = double.INFINITY;
    } else if (freq == double.INFINITY) {
      _periodSecs = 0.0;
    } else {
      _periodSecs = 1 / freq;
    }
  }
  get frequency => 1 / _periodSecs;

  @override
  bool _canExecute() {
    if (!precondition()) return false;
    if (_periodSecs == double.INFINITY) return false;
    if (_periodSecs == 0.0) return true;

    bool canExecute = _secsSinceLastExecute > _periodSecs;
    if (canExecute) {
      _secsSinceLastExecute = 0.0;
    }
    return canExecute;
  }

  void update(double deltaT) {
    _secsSinceLastExecute += deltaT;
  }
}
