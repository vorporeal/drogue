library sidebar;

import 'dart:html';

class Sidebar {
  static decorate(Element e) {
    e.querySelector('.toggle').onClick.listen((_) => e.classes.toggle('closed'));
  }
}
