part of gfx;

class Renderer {
  final int width, height;
  Vector2 _viewportSize;
  b2d.DebugDraw _b2dCanvasDraw;

  /**
   * The canvas which the game is rendered into.  Note that users of this class
   * will need to explicitly insert this element into the document.
   */
  CanvasElement _canvas;

  Renderer({this.width: 800, this.height: 600}) {
    this._canvas = new CanvasElement(width: width, height: height);
    this._viewportSize = new Vector2(
        canvas.width.toDouble(), canvas.height.toDouble());

    _canvas..id = 'canvas'
           ..tabIndex = 0
           ..style.width = '${_canvas.width}px'
           ..style.height = '${_canvas.height}px';


     // Configure debug rendering for box2d.
     var center = viewportSize * 0.5;
     var extents = center.clone();
     var viewport = new b2d.ViewportTransform(extents, center, 1.0);
    _b2dCanvasDraw = new b2d.CanvasDraw(viewport, ctx);
  }

  CanvasElement get canvas => _canvas;
  CanvasRenderingContext2D get ctx => _canvas.getContext('2d');

  b2d.CanvasDraw get b2dCanvasDraw => _b2dCanvasDraw;

  Vector2 get viewportSize => _viewportSize;
}