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
       ..lineWidth = 2
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
  Player() : super(width: 50.0, height: 50.0) {
    strokeStyle = 'red';
    fillStyle = 'rgba(255, 0, 0, 0.3)';
  }
}


class Projectile extends Entity {
  static const double SPEED = 300 / 1000;
  static double _maxDistance = 500.0;

  double _distanceTravelled = 0.0;
  Vector2 _direction;

  Projectile(Vector2 position, this._direction) : super(width: 10.0, height: 10.0) {
    // Store the projectile in the global list.
    Projectiles._list.add(this);

    // Set some stuff.
    center = position;
    strokeStyle = 'rgb(100, 149, 237)';
    fillStyle = 'rgba(100, 149, 237, 0.3)';

    // Ensure our direction is a unit vector.
    _direction.normalize();
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

class Projectiles {
  static final List<Projectile> _list = [];

  static List<Projectile> get all => _list;
  static int get count => _list.length;

  static updateAll(double deltaT) {
    _list.forEach((p) => p.move(deltaT));
    _list.removeWhere((p) => !p.isAlive());
  }

  static renderAll(CanvasRenderingContext2D ctx) {
    _list.forEach((p) => p.draw(ctx));
  }
}
