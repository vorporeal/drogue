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
  double _periodInMillis = double.INFINITY;
  double _millisSinceLastExecute = 0.0;

  RateLimiter.of(Function f) : super.of(f);

  set frequency(double freq) {
    if (freq == 0.0) {
      _periodInMillis = double.INFINITY;
    } else if (freq == double.INFINITY) {
      _periodInMillis = 0.0;
    } else {
      _periodInMillis = 1000.0 / freq;
    }
  }
  get frequency => _periodInMillis / 1000.0;

  @override
  bool _canExecute() {
    if (!precondition()) return false;
    if (_periodInMillis == double.INFINITY) return false;
    if (_periodInMillis == 0.0) return true;

    bool canExecute = _millisSinceLastExecute > _periodInMillis;
    if (canExecute) {
      _millisSinceLastExecute = 0.0;
    }
    return canExecute;
  }

  void update(double deltaT) {
    _millisSinceLastExecute += deltaT;
  }
}
