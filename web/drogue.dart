import 'game.dart';
import 'input.dart';
import 'entities.dart';
import 'limiters.dart';
import 'sidebar.dart';

import 'package:vector_math/vector_math.dart';

import 'dart:html' hide Player;

const double MOVE_SPEED = 2000.0;

final Game game = new Game.instance();
final Rock rock = new Rock(new Vector2(100.0, 100.0));

Player player;

void movePlayer(double deltaT) {
  var input = game.input;

  // Move the player based on keyboard input.
  Vector2 playerDir = new Vector2.zero();
  if (input.isPressed(Key.MOVE_LEFT)) {
    playerDir.x -= 1;
  }
  if (input.isPressed(Key.MOVE_RIGHT)) {
    playerDir.x += 1;
  }
  if (input.isPressed(Key.MOVE_UP)) {
    playerDir.y += 1;
  }
  if (input.isPressed(Key.MOVE_DOWN)) {
    playerDir.y -= 1;
  }

  playerDir.normalize();
  player.body.linearVelocity.setFrom(playerDir * MOVE_SPEED);
}

void createProjectiles() {
  var input = game.input;

  // TODO: Don't create a projectile for each shoot key which is depressed, only
  //    the one which was pressed most recently.
  Key.shootKeys.where((key) => input.isPressed(key)).forEach((key) {
    var direction = Key.toDirection(key);
    var offset = new Vector2.all(Projectile.SIZE)
        .add(player.size)
        .scale(0.5)
        .multiply(direction);
    new Projectile(player.center.add(offset), Key.toDirection(key));
  });
}

// Define a rate-limited version of createProjectiles() which will create a
// projectile if a shoot key is currently depressed, but not more than once
// every 3 seconds.
RateLimiter maybeCreateProjectiles =
    new RateLimiter.of(createProjectiles)
        ..frequency = 3.0
        ..precondition = () => Key.shootKeys.any(
            (key) => game.input.isPressed(key));

void render(double deltaT) {
  var ctx = game.renderer.ctx;

  // Clear the canvas.
  //ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = '#444';
  ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

  // Draw the player.
  player.draw(ctx);

  // Draw the rock.
  rock.draw(ctx);

  // Draw the projectiles.
  Projectiles.renderAll(ctx);
}

void updateStats(double deltaT) {
  // Update the FPS counter.
  querySelector('.counter.fps').setInnerHtml(game.loop.fps.toString());
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
  game.loop.onTick
      // Update rate limiters.
      ..listen(maybeCreateProjectiles.update)
      // Move the player.
      ..listen(movePlayer)
      // If necessary, create new projectiles.
      ..listen((_) => maybeCreateProjectiles())
      // Move all projectiles.
      ..listen(Projectiles.updateAll)
      // Update the world simulation.
      ..listen((_) => game.world.step(
          Game.SIMULATION_STEP, Game.VELOCITY_ITERS, Game.POSITION_ITERS))
      // Render the scene.
      ..listen(render)
      // Render box2d debug data.
      ..listen((_) => game.world.drawDebugData())
      // Update stats.
      ..listen(updateStats);

  // Start the game.
  game.start();
}


void _initializePlayer() {
  // Set up the player entity.
  //var position = game.renderer.viewportSize * 0.5;
  var position = new Vector2.zero();
  player = new Player(position);
}

void _initializeCanvas() {
  var canvas = game.renderer.canvas;

  // Insert the canvas element into the DOM.
  querySelector('#container').children.add(canvas);
  // Focus the canvas element (so keyboard input is captured).
  canvas.focus();
}
