library entities;

import 'package:box2d/box2d_browser.dart' as b2d;
import 'package:vector_math/vector_math.dart';

import 'game.dart';

import 'dart:html';

const int CATEGORY_PLAYER      = 0x0001;
const int CATEGORY_PROJECTILE  = 0x0002;
const int CATEGORY_OTHER       = 0x0004;

const int GROUP_PROJECTILE     = -1;

abstract class Entity {
  static final game = new Game.instance();
  String strokeStyle = 'black',
         fillStyle   = 'grey';

  b2d.Body body;

  Entity();

  void draw(ctx) {
    var offset = size / 2.0
        ..y *= -1;
    var topLeft = center.sub(offset);

    // Transform the world coordinates into screen coordinates.
    var canvasDraw = game.renderer.b2dCanvasDraw;
    canvasDraw.getWorldToScreenToOut(topLeft, topLeft);

    ctx..strokeStyle = strokeStyle
       ..lineWidth = 2
       ..fillStyle = fillStyle
       ..strokeRect(topLeft.x, topLeft.y, size.x, size.y)
       ..fillRect(topLeft.x, topLeft.y, size.x, size.y);
  }

  Vector2 get size;
  Vector2 get center => body.position.clone();
}


class Player extends Entity {
  static const double SIZE = 50.0;

  static final b2d.BodyDef _bodyDef = new b2d.BodyDef()
      ..type = b2d.BodyType.DYNAMIC
      ..fixedRotation = true
      ..allowSleep = false;
  static final Vector2 _size = new Vector2(SIZE, SIZE);

  Player(Vector2 position) {
    strokeStyle = 'red';
    fillStyle = 'rgba(255, 0, 0, 0.3)';

    // Set the initial position of the player.
    _bodyDef.position.setFrom(position);

    // Create a box2d body for the player.
    var shape = new b2d.PolygonShape()
        ..setAsBox(size.x / 2, size.y / 2);
    var fixtureDef = new b2d.FixtureDef()
        ..shape = shape
        ..filter.categoryBits = CATEGORY_PLAYER;
    body = Entity.game.world.createBody(_bodyDef)
        ..createFixture(fixtureDef);
  }

  Vector2 get size => _size;
}


class Projectile extends Entity {
  static const double SIZE = 10.0;
  static const double SPEED = 300.0;

  static final Vector2 _size = new Vector2(SIZE, SIZE);
  static final b2d.BodyDef _bodyDef = new b2d.BodyDef()
        ..type = b2d.BodyType.DYNAMIC
        ..angularDamping = 1.0
        ..active = true;

  static double _maxDistance = 500.0;

  double _distanceTravelled = 0.0;
  final Vector2 _direction;

  Projectile(Vector2 position, this._direction) {
    // Store the projectile in the global list.
    Projectiles._list.add(this);

    // Set rendering parameters.
    strokeStyle = 'rgb(100, 149, 237)';
    fillStyle = 'rgba(100, 149, 237, 0.3)';

    // Ensure _direction is a unit vector.
    _direction.normalize();

    // Set the initial position of the projectile.
    _bodyDef..position.setFrom(position);

    // Create a box2d body for the projectile.
    var shape = new b2d.PolygonShape()
        ..setAsBox(size.x / 2, size.y / 2);
    var fixtureDef = new b2d.FixtureDef()
        ..friction = 0.0
        ..restitution = 1.0
        ..shape = shape
        ..filter.groupIndex = GROUP_PROJECTILE
        ..filter.categoryBits = CATEGORY_PROJECTILE
        ..filter.maskBits = ~CATEGORY_PLAYER
        ..userData = this;
    body = Entity.game.world.createBody(_bodyDef)
        ..createFixture(fixtureDef)
        ..linearVelocity.setFrom(_direction * SPEED);
  }

  Vector2 get size => _size;

  void update(double deltaT) {
    var distance = SPEED * deltaT;
    _distanceTravelled += distance;

    // If this projectile is dead, destroy it's physical body.
    if (!isAlive()) {
      body.world.destroyBody(body);
    }
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
    _list..forEach((p) => p.update(deltaT))
         ..removeWhere((p) => !p.isAlive());
  }

  static renderAll(CanvasRenderingContext2D ctx) {
    _list.forEach((p) => p.draw(ctx));
  }
}

class Rock extends Entity {
  static const double SIZE = 50.0;

  static final Vector2 _size = new Vector2(SIZE, SIZE);
  static final b2d.BodyDef _bodyDef = new b2d.BodyDef()
      ..type = b2d.BodyType.STATIC;

  b2d.Body body;

  Rock(Vector2 position) {

    // Set rendering params.
    strokeStyle = 'rgb(191, 255, 0)';
    fillStyle = 'rgba(191, 255, 0, 0.3)';

    // Set the position of the rock.
    _bodyDef..position.setFrom(position);

    // Create a box2d body for this rock.
    var shape = new b2d.PolygonShape()
        ..setAsBox(size.x / 2, size.y / 2);
    var fixtureDef = new b2d.FixtureDef()
        ..shape = shape
        ..filter.categoryBits = CATEGORY_OTHER;
    body = Entity.game.world.createBody(_bodyDef)
        ..createFixture(fixtureDef);
  }

  Vector2 get size => _size;
}
