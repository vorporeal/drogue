library input;

import 'package:vector_math/vector_math.dart';

import 'dart:async';
import 'dart:html';


class Key {
  // Key "enum" constants
  static const
      MOVE_LEFT = const Key._(KeyCode.A),
      MOVE_RIGHT = const Key._(KeyCode.D),
      MOVE_UP = const Key._(KeyCode.W),
      MOVE_DOWN = const Key._(KeyCode.S),
      SHOOT_LEFT = const Key._(KeyCode.LEFT),
      SHOOT_RIGHT = const Key._(KeyCode.RIGHT),
      SHOOT_UP = const Key._(KeyCode.UP),
      SHOOT_DOWN = const Key._(KeyCode.DOWN);

  // Variables

  static Map<int, Key> _codeToKey = new Map.fromIterable(values,
      key: (Key key) => key.keyCode);

  final int keyCode;

  // Constructors

  const Key._(this.keyCode);

  factory Key.fromCode(int keyCode) => _codeToKey[keyCode];

  // Static methods

  static List<Key> get values => [
      MOVE_LEFT,
      MOVE_RIGHT,
      MOVE_UP,
      MOVE_DOWN,
      SHOOT_LEFT,
      SHOOT_RIGHT,
      SHOOT_UP,
      SHOOT_DOWN,
  ];

  static List<Key> get shootKeys =>
      values.where((key) => isShootKey(key)).toList(growable: false);

  static Vector2 toDirection(Key key) {
    switch(key) {
      case MOVE_LEFT:
      case SHOOT_LEFT:
        return new Vector2(-1.0, 0.0);
      case MOVE_RIGHT:
      case SHOOT_RIGHT:
        return new Vector2(1.0, 0.0);
      case MOVE_UP:
      case SHOOT_UP:
        return new Vector2(0.0, -1.0);
      case MOVE_DOWN:
      case SHOOT_DOWN:
        return new Vector2(0.0, 1.0);
      default:
        return null;
    }
  }

  static bool isUsedKeyCode(int keyCode) =>
      _codeToKey.containsKey(keyCode);

  static bool isShootKey(Key key) {
    return key == SHOOT_LEFT || key == SHOOT_RIGHT ||
           key == SHOOT_UP || key == SHOOT_DOWN;
  }

  static bool isMoveKey(Key key) {
    return key == MOVE_LEFT || key == MOVE_RIGHT ||
           key == MOVE_UP || key == MOVE_DOWN;
  }
}


class KeyboardHelper {
  final Map<int, bool> _keyMap = new Map();
  final Element _eventTarget;
  Stream onKey;

  KeyboardHelper(this._eventTarget) {
    _eventTarget..onKeyDown.listen((e) => handleKeyboardEvent(e))
                ..onKeyUp.listen((e) => handleKeyboardEvent(e));

    onKey = _eventTarget.onKeyDown
        .map((KeyboardEvent e) => new KeyEvent.wrap(e))
        .where((KeyEvent e) => Key.isUsedKeyCode(e.keyCode))
        .map((KeyEvent e) => new Key.fromCode(e.keyCode))
        .asBroadcastStream();
  }

  void handleKeyboardEvent(KeyboardEvent e) {
    bool isDown = e.type == 'keydown';
    int keyCode = new KeyEvent.wrap(e).keyCode;
    _keyMap[keyCode]= isDown;
  }

  bool isPressed(Key key) {
    return _keyMap.containsKey(key.keyCode) ? _keyMap[key.keyCode] : false;
  }
}
