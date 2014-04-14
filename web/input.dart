library input;

import 'package:vector_math/vector_math.dart';

import 'dart:async';
import 'dart:html';


class Key {
  // Key "enum" constants
  static const
      MOVE_LEFT = const Key._(65),     // A
      MOVE_RIGHT = const Key._(68),    // D
      MOVE_UP = const Key._(87),       // W
      MOVE_DOWN = const Key._(83),     // S
      SHOOT_LEFT = const Key._(37),    // Left
      SHOOT_RIGHT = const Key._(39),   // Right
      SHOOT_UP = const Key._(38),      // Up
      SHOOT_DOWN = const Key._(40);    // Down

  // Variables

  static Map<int, Key> _codeToKey = new Map.fromIterable(values,
      key: (Key key) => key.keyCode);

  final int keyCode;

  // Constructors

  const Key._(this.keyCode);

  factory Key.fromCode(int keyCode) => _codeToKey[keyCode];

  // Static methods

  static get values => [
      MOVE_LEFT,
      MOVE_RIGHT,
      MOVE_UP,
      MOVE_DOWN,
      SHOOT_LEFT,
      SHOOT_RIGHT,
      SHOOT_UP,
      SHOOT_DOWN,
  ];

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
  final Map<Key, bool> _keyMap = new Map();
  final Element _eventTarget;
  Stream onKey;

  KeyboardHelper(this._eventTarget) {
    _eventTarget..onKeyDown.listen((e) => _keyMap[e.keyCode] = true)
                ..onKeyUp.listen((e) => _keyMap[e.keyCode] = false);

    onKey = _eventTarget.onKeyDown
        .where((e) => Key.isUsedKeyCode(e.keyCode))
        .map((e) => new Key.fromCode(e.keyCode))
        .asBroadcastStream();
  }

  bool isPressed(Key key) {
    return _keyMap.containsKey(key.keyCode) ? _keyMap[key.keyCode] : false;
  }
}
