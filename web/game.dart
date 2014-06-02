library game;

import 'package:box2d/box2d_browser.dart' as b2d;

import 'core.dart';
import 'gfx.dart';
import 'input.dart';

class Game {
  static final Game _instance = new Game._internal();

  static const double SIMULATION_STEP = 1 / 60;
  static const int VELOCITY_ITERS = 10;
  static const int POSITION_ITERS = 10;

  final b2d.World world = new b2d.World(
        new b2d.Vector2.zero() /* gravity */,
        true /* doSleep */,
        new b2d.DefaultWorldPool());

  final GameLoop loop = new GameLoop();
  final Renderer renderer = new Renderer();

  KeyboardHelper _input;
  KeyboardHelper get input => _input;

  /**
   * Get the singleton instance of Game.
   */
  factory Game.instance() => _instance;

  /**
   * Private constructor.
   */
  Game._internal() {
    _input = new KeyboardHelper(renderer.canvas);

    // Set up the box2d debug renderer.
    //world.debugDraw = renderer.b2dCanvasDraw;
  }

  void start() {
    loop.start();
  }
}