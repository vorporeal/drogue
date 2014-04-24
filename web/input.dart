library input;

import 'package:vector_math/vector_math.dart';

import 'dart:async';
import 'dart:html';


class Key {
  // Key "enum" constants
  static const
      MOVE_LEFT =   const Key._(     1, KeyCode.A),
      MOVE_RIGHT =  const Key._(     2, KeyCode.D),
      MOVE_UP =     const Key._(     4, KeyCode.W),
      MOVE_DOWN =   const Key._(     8, KeyCode.S),
      SHOOT_LEFT =  const Key._(    16, KeyCode.LEFT),
      SHOOT_RIGHT = const Key._(    32, KeyCode.RIGHT),
      SHOOT_UP =    const Key._(    64, KeyCode.UP),
      SHOOT_DOWN =  const Key._(   128, KeyCode.DOWN);

  // Variables

  static Map<int, Key> _codeToKey = new Map.fromIterable(values,
      key: (Key key) => key.keyCode);

  final int _value;
  final int keyCode;

  // Constructors

  const Key._(this._value, this.keyCode);

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
  Stream onKeyDown;

  int _keyState = 0;

  KeyboardHelper(this._eventTarget) {
    _eventTarget..onKeyDown.listen((e) => handleKeyboardEvent(e))
                ..onKeyUp.listen((e) => handleKeyboardEvent(e));

    onKeyDown = _eventTarget.onKeyDown
        .map((KeyboardEvent e) => new KeyEvent.wrap(e))
        .where((KeyEvent e) => Key.isUsedKeyCode(e.keyCode))
        .map((KeyEvent e) => new Key.fromCode(e.keyCode))
        .asBroadcastStream();
  }

  void handleKeyboardEvent(KeyboardEvent e) {
    var keyCode = new KeyEvent.wrap(e).keyCode;
    var key = new Key.fromCode(keyCode);

    if (key == null) return;

    if (e.type == 'keydown') {
      _keyState |= key._value;
    } else {
      _keyState &= ~key._value;
    }
  }

  bool isPressed(Key key) {
    return (_keyState & key._value) != 0;
  }
}
