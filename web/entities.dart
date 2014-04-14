library entities;

import 'package:vector_math/vector_math.dart';

import 'dart:html';
import 'dart:math';

class Entity {
  MutableRectangle<double> rect;
  String strokeStyle = 'black',
         fillStyle   = 'grey';

  Entity({double left: 0.0, double top: 0.0,
      double width: 30.0, double height: 30.0}) {
    rect = new MutableRectangle(left, top, width, height);
  }

  void draw(CanvasRenderingContext2D ctx) {
    ctx..strokeStyle = strokeStyle
       ..lineWidth = 3
       ..fillStyle = fillStyle
       ..strokeRect(rect.left, rect.top, rect.width, rect.height)
       ..fillRect(rect.left, rect.top, rect.width, rect.height);
  }

  Vector2 get size => new Vector2(rect.width, rect.height);

  Vector2 get center =>
      new Vector2(rect.left + 0.5 * rect.width, rect.top + 0.5 * rect.height);
  set center(Vector2 v) => rect..left = v.x - 0.5 * rect.width
                               ..top  = v.y - 0.5 * rect.height;
}


class Player extends Entity {
  Player() : super(width: 50.0, height: 50.0);
}


class Projectile extends Entity {
  static const double SPEED = 300 / 1000;
  static double _maxDistance = 500.0;

  double _distanceTravelled = 0.0;
  Vector2 _direction;

  Projectile(Vector2 position, this._direction) : super(width: 10.0, height: 10.0) {
    this.fillStyle = '#6495ED';

    this.center = position;
    // Ensure our direction is a unit vector.
    this._direction.normalize();
  }

  void move(double deltaT) {
    var distance = SPEED * deltaT;
    var moveVector = _direction * distance;
    _distanceTravelled += distance;
    center = center + _direction * SPEED * deltaT;
  }

  bool isAlive() {
    return _distanceTravelled <= _maxDistance;
  }
}
