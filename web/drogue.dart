import 'input.dart';
import 'entities.dart';

import 'package:vector_math/vector_math.dart';

import 'dart:html' hide Player;
import 'dart:math';

const int WIDTH = 800,
    HEIGHT = 600;
final Vector2 CANVAS_SIZE = new Vector2(WIDTH.toDouble(), HEIGHT.toDouble());

const double MOVE_SPEED = 200 / 1000;

double timeOfLastFrame = 0.0;

Player player;
CanvasElement canvas;
CanvasRenderingContext2D ctx;
Rectangle screenRect = new Rectangle(0, 0, WIDTH, HEIGHT);

List<Projectile> projectiles = [];

KeyboardHelper input;

void movePlayer(double deltaT) {
  // Move the player, if necessary.
  if (input.isPressed(Key.MOVE_LEFT)) {
    player.rect.left -= deltaT * MOVE_SPEED;
  }
  if (input.isPressed(Key.MOVE_RIGHT)) {
    player.rect.left += deltaT * MOVE_SPEED;
  }
  if (input.isPressed(Key.MOVE_UP)) {
    player.rect.top -= deltaT * MOVE_SPEED;
  }
  if (input.isPressed(Key.MOVE_DOWN)) {
    player.rect.top += deltaT * MOVE_SPEED;
  }
}

void moveProjectiles(double deltaT) {
  for (var projectile in projectiles) {
    projectile.move(deltaT);
  }
  projectiles.removeWhere((Projectile p) => !p.isAlive());
}

void render() {
  // Clear the canvas.
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Draw the player.
  player.draw(ctx);

  // Draw the projectiles.
  for (var projectile in projectiles) {
   projectile.draw(ctx);
  }
  // Update the projectile counter (debugging info).
  querySelector('#projectile-counter').setInnerHtml(
     projectiles.length.toString());
}

void tick(double frameTime) {
  // Get the delta (in microseconds) between this frame and the last.
  double deltaT = frameTime - timeOfLastFrame;
  timeOfLastFrame = frameTime;

  movePlayer(deltaT);
  moveProjectiles(deltaT);

  render();

  // Request that we run again next frame.
  window.animationFrame.then(tick);
}

void main() {
  _initializeCanvas();
  _initializePlayer();

  // If the user presses shoot, create a new projectile.
  input.onKey.where((Key key) => Key.isShootKey(key)).listen((Key key) {
    projectiles.add(new Projectile(player.center, Key.toDirection(key)));
  });

  // Start the game loop.
  window.animationFrame.then((time) => timeOfLastFrame = time).then(tick);
}


void _initializePlayer() {
  // Set up the player entity.
  player = new Player();
  player.center = (CANVAS_SIZE - player.size) * 0.5;
}

void _initializeCanvas() {
  // Set up the drawing canvas.
  canvas = new CanvasElement(width: WIDTH, height: HEIGHT);
  canvas..id = 'canvas'
        ..tabIndex = 0
        ..style.width = '${canvas.width}px'
        ..style.height = '${canvas.height}px';
  // Insert the canvas element into the DOM.
  querySelector('#container').children.add(canvas);

  // Listen for input events on the canvas.
  input = new KeyboardHelper(canvas);

  // Get the 2d rendering context.
  ctx = canvas.getContext('2d');
}
