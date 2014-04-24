import 'input.dart';
import 'entities.dart';
import 'limiters.dart';
import 'sidebar.dart';
import 'gameloop.dart';

import 'package:vector_math/vector_math.dart';

import 'dart:html' hide Player;
import 'dart:math';

const int WIDTH = 800,
    HEIGHT = 600;
final Vector2 CANVAS_SIZE = new Vector2(WIDTH.toDouble(), HEIGHT.toDouble());

const double MOVE_SPEED = 200 / 1000;

GameLoop gameLoop = new GameLoop();
Player player;
CanvasElement canvas;
CanvasRenderingContext2D ctx;
Rectangle screenRect = new Rectangle(0, 0, WIDTH, HEIGHT);

KeyboardHelper input;

void movePlayer(double deltaT) {
  // Move the player based on keyboard input.
  Vector2 playerDir = new Vector2.zero();
  if (input.isPressed(Key.MOVE_LEFT)) {
    playerDir.x -= 1;
  }
  if (input.isPressed(Key.MOVE_RIGHT)) {
    playerDir.x += 1;
  }
  if (input.isPressed(Key.MOVE_UP)) {
    playerDir.y -= 1;
  }
  if (input.isPressed(Key.MOVE_DOWN)) {
    playerDir.y += 1;
  }

  playerDir.normalize();
  playerDir *= deltaT * MOVE_SPEED;
  player.rect..left += playerDir.x
             ..top  += playerDir.y;

}

void createProjectiles() {
  Key.shootKeys.where((key) => input.isPressed(key)).forEach((key) {
    new Projectile(player.center, Key.toDirection(key));
  });
}

RateLimiter maybeCreateProjectiles =
    new RateLimiter.of(createProjectiles)
        ..frequency = 3.0;

void render(double deltaT) {
  // Clear the canvas.
  //ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = '#444';
  ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

  // Draw the player.
  player.draw(ctx);

  // Draw the projectiles.
  Projectiles.renderAll(ctx);
}

void updateStats(double deltaT) {
  // Update the FPS counter.
  querySelector('.counter.fps').setInnerHtml(gameLoop.fps.update(deltaT));
  // Update the projectile counter.
  querySelector('.counter.projectiles').setInnerHtml(
    Projectiles.count.toString());
}

void main() {
  _initializeCanvas();
  _initializePlayer();

  // Set up event handling for sidebars.
  querySelectorAll('.sidebar').forEach((el) => Sidebar.decorate(el));

  // Configure all per-tick updates.
  gameLoop.onTick
      // Update rate limiters.
      ..listen(maybeCreateProjectiles.update)
      // Move the player.
      ..listen(movePlayer)
      // If a shoot key is pressed, create new projectiles.
      ..where((_) => Key.shootKeys.any((key) => input.isPressed(key)))
          .listen((_) => maybeCreateProjectiles())
      // Move all projectiles.
      ..listen(Projectiles.updateAll)
      // Render the scene.
      ..listen(render)
      // Update stats.
      ..listen(updateStats);

  // Start the game loop.
  gameLoop.start();
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
  // Focus the canvas element (so keyboard input is captured).
  canvas.focus();

  // Listen for input events on the canvas.
  input = new KeyboardHelper(canvas);

  // Get the 2d rendering context.
  ctx = canvas.getContext('2d');
}
