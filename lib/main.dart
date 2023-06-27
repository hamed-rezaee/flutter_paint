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
  final List<double> _lineWidths = <double>[1];

  Color _selectedColor = Colors.black;
  double _lineWidth = 4;

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
              _lineWidths.add(_lineWidth);
            });
          },
          onPanEnd: (DragEndDetails details) {
            _points.add(null);
            _lineColors.add(Colors.transparent);
            _lineWidths.add(0);
          },
          child: CustomPaint(
            painter: PaintCanvas(
              points: _points,
              lineColors: _lineColors,
              lineWidths: _lineWidths,
            ),
            size: Size.infinite,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.color_lens, color: _selectedColor),
                onPressed: () => _showColorPicker(),
              ),
              SizedBox(
                height: 16,
                child: Slider(
                  value: _lineWidth,
                  min: 1,
                  max: 80,
                  divisions: 79,
                  onChanged: (double value) =>
                      setState(() => _lineWidth = value),
                ),
              ),
              Text(
                '${_lineWidth.ceil()}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() {
                  _points.clear();
                  _lineColors.clear();
                  _lineWidths.clear();
                }),
              ),
            ],
          ),
        ),
      );

  void _showColorPicker() => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Select a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() => _selectedColor = color);

                Navigator.of(context).pop();
              },
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
  PaintCanvas({
    required this.points,
    required this.lineColors,
    required this.lineWidths,
  });

  final List<Offset?> points;
  final List<Color> lineColors;
  final List<double> lineWidths;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        paint
          ..color = lineColors[i]
          ..strokeWidth = lineWidths[i];

        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
