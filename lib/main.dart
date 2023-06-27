import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(PaintApp());

class PaintApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: PaintScreen());
}

class PaintScreen extends StatefulWidget {
  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final List<Offset?> _points = <Offset?>[];
  final List<Color> _lineColors = <Color>[Colors.black];

  Color _selectedColor = Colors.black;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(elevation: 0, title: const Text('Flutter Paint')),
        body: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;

              _points.add(renderBox.globalToLocal(details.localPosition));
              _lineColors.add(_selectedColor);
            });
          },
          onPanEnd: (DragEndDetails details) {
            _points.add(null);
            _lineColors.add(Colors.transparent);
          },
          child: CustomPaint(
            painter: PaintCanvas(points: _points, lineColors: _lineColors),
            size: Size.infinite,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.color_lens, color: _selectedColor),
                onPressed: () => showColorPicker(),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() {
                  _points.clear();
                  _lineColors.clear();
                }),
              ),
            ],
          ),
        ),
      );

  void showColorPicker() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (Color color) =>
                setState(() => _selectedColor = color),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
}

class PaintCanvas extends CustomPainter {
  PaintCanvas({required this.points, required this.lineColors});

  final List<Offset?> points;
  final List<Color> lineColors;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        paint.color = lineColors[i];
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
