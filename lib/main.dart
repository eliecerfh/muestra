import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puntos Interactivos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Point> points = [
    Point(id: '1', name: 'Lunes', x: 0.2, y: 0.2),
    Point(id: '2', name: 'Martes', x: 0.4, y: 0.4),
    Point(id: '3', name: 'Miércoles', x: 0.6, y: 0.6),
    Point(id: '4', name: 'Jueves', x: 0.8, y: 0.8),
    Point(id: '5', name: 'Viernes', x: 1.0, y: 1.0),
  ];

  double _scale = 1.0;
  late Offset _previousOffset;
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _previousOffset = details.focalPoint;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale *= details.scale;
          _scale = _scale.clamp(0.5,
              2.0); // Limita el rango de escala para evitar valores extremos
          _offset += (details.focalPoint - _previousOffset) / _scale;
          _previousOffset = details.focalPoint;
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Transform.translate(
                offset: _offset,
                child: Transform.scale(
                  scale: _scale,
                  child: CustomPaint(
                    painter: PointPainter(points, _scale, _offset, context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Point {
  final String id;
  final String name;
  final double x;
  final double y;

  Point({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
  });
}

class PointPainter extends CustomPainter {
  final List<Point> points;
  final double scale;
  final Offset offset;
  final BuildContext context;
  final double pointRadius = 10.0;
  final Color pointColor = Colors.red;
  final Paint pointPaint = Paint()..color = Colors.red;
  final Paint linePaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2.0;

  PointPainter(this.points, this.scale, this.offset, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      final Point p = points[i];
      final Offset pointOffset = Offset(p.x * size.width, p.y * size.height);
      canvas.drawCircle(pointOffset, pointRadius / scale, pointPaint);

      final TextSpan span = TextSpan(
          text: p.name,
          style: const TextStyle(
              color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      PointDetailScreen(point: p)));
            });

      final TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(
          canvas,
          Offset(pointOffset.dx - (tp.width / 2),
              pointOffset.dy - (tp.height * 1.5 / scale)));

      if (i < points.length - 1) {
        final Point next = points[i + 1];
        final Offset nextOffset =
            Offset(next.x * size.width, next.y * size.height);
        canvas.drawLine(pointOffset, nextOffset, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(PointPainter oldDelegate) {
    return points != oldDelegate.points ||
        scale != oldDelegate.scale ||
        offset != oldDelegate.offset;
  }
}

class PointDetailScreen extends StatelessWidget {
  final Point point;

  const PointDetailScreen({Key? key, required this.point}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(point.name),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${point.id}',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Nombre: ${point.name}',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Coordenadas:',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              '- X: ${point.x}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              '- Y: ${point.y}',
              style: const TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
