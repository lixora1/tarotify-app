import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// El falı — renkli çizgi overlay ve açıklama paneli
class HandLinesOverlay extends StatefulWidget {
  final File image;
  const HandLinesOverlay({super.key, required this.image});

  @override
  State<HandLinesOverlay> createState() => _HandLinesOverlayState();
}

class _HandLinesOverlayState extends State<HandLinesOverlay>
    with SingleTickerProviderStateMixin {
  int? _selectedLine;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const List<HandLine> _lines = [
    HandLine(
      id: 0,
      name: 'Yaşam Çizgisi',
      emoji: '🌿',
      color: Color(0xFF4CAF50),
      description:
          'Yaşam enerjinizi, sağlık durumunuzu ve uzun ömürlülüğünüzü temsil eder. '
          'Uzun ve derin bir çizgi güçlü bir yaşam enerjisine işaret eder.',
      // Normalized positions (0.0 - 1.0) for a typical right palm
      points: [
        Offset(0.38, 0.22),
        Offset(0.34, 0.35),
        Offset(0.30, 0.50),
        Offset(0.28, 0.65),
        Offset(0.30, 0.78),
      ],
    ),
    HandLine(
      id: 1,
      name: 'Kalp Çizgisi',
      emoji: '❤️',
      color: Color(0xFFE91E63),
      description:
          'Duygusal dünyayı, aşkı ve ilişkileri yansıtır. '
          'Uzun ve kıvrımlı bir çizgi derin duygusal bağlar kurduğunuzu gösterir.',
      points: [
        Offset(0.22, 0.30),
        Offset(0.35, 0.27),
        Offset(0.50, 0.25),
        Offset(0.65, 0.26),
        Offset(0.75, 0.28),
      ],
    ),
    HandLine(
      id: 2,
      name: 'Kafa Çizgisi',
      emoji: '🧠',
      color: Color(0xFF2196F3),
      description:
          'Zeka, analitik düşünce ve karar verme yeteneğini temsil eder. '
          'Düz bir çizgi pratik zekaya, eğri bir çizgi yaratıcı düşünceye işaret eder.',
      points: [
        Offset(0.28, 0.42),
        Offset(0.40, 0.43),
        Offset(0.52, 0.44),
        Offset(0.64, 0.46),
        Offset(0.74, 0.50),
      ],
    ),
    HandLine(
      id: 3,
      name: 'Kader Çizgisi',
      emoji: '⭐',
      color: Color(0xFFFFC107),
      description:
          'Kariyer yolculuğunu, başarıyı ve hayatınızdaki büyük değişimleri gösterir. '
          'Güçlü bir çizgi net bir yaşam amacına işaret eder.',
      points: [
        Offset(0.50, 0.80),
        Offset(0.50, 0.65),
        Offset(0.50, 0.50),
        Offset(0.50, 0.38),
        Offset(0.48, 0.28),
      ],
    ),
    HandLine(
      id: 4,
      name: 'Güneş Çizgisi',
      emoji: '☀️',
      color: Color(0xFFFF9800),
      description:
          'Yaratıcılık, şöhret ve maddi başarıyı temsil eder. '
          'Bu çizginin varlığı sanatsal yeteneklere ve toplumsal tanınırlığa işaret eder.',
      points: [
        Offset(0.65, 0.75),
        Offset(0.64, 0.62),
        Offset(0.63, 0.50),
        Offset(0.62, 0.40),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            '🖐 El çizgilerinize dokunun',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
        // El görseli + overlay
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 0.85,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // El fotoğrafı
                Image.file(widget.image, fit: BoxFit.cover),
                // Karartma katmanı
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.30),
                      ],
                    ),
                  ),
                ),
                // Çizgi overlay
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: HandLinesPainter(
                        lines: _lines,
                        selectedLine: _selectedLine,
                        pulseValue: _pulseAnim.value,
                      ),
                    );
                  },
                ),
                // Dokunma algılama
                GestureDetector(
                  onTapDown: (details) => _onTap(context, details),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Çizgi legend
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _lines.map((line) {
            final isSelected = _selectedLine == line.id;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedLine = isSelected ? null : line.id;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? line.color.withOpacity(0.2)
                      : AppTheme.cardBg,
                  border: Border.all(
                    color: isSelected ? line.color : AppTheme.cardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: line.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${line.emoji} ${line.name}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? line.color : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        // Seçili çizgi açıklaması
        if (_selectedLine != null) ...[
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildLineInfo(_lines[_selectedLine!]),
          ),
        ],
      ],
    );
  }

  Widget _buildLineInfo(HandLine line) {
    return Container(
      key: ValueKey(line.id),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: line.color.withOpacity(0.08),
        border: Border.all(color: line.color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(line.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: TextStyle(
                    color: line.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  line.description,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, TapDownDetails details) {
    // Hangi çizgiye yakın dokunuldu?
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    // AspectRatio hesapla
    final size = box.size;
    // Görselin gerçek çizim alanı
    final imgWidth = size.width;
    final imgHeight = size.width / 0.85;
    final imgTop = (size.height - imgHeight) / 2;

    final localPos = details.localPosition;
    final normalizedX = (localPos.dx) / imgWidth;
    final normalizedY = (localPos.dy - imgTop.clamp(0, double.infinity)) / imgHeight;

    double minDist = 0.06;
    int? closest;

    for (final line in _lines) {
      for (final pt in line.points) {
        final dx = pt.dx - normalizedX;
        final dy = pt.dy - normalizedY;
        final dist = (dx * dx + dy * dy);
        if (dist < minDist * minDist) {
          minDist = dist;
          closest = line.id;
        }
      }
    }

    setState(() => _selectedLine = closest == _selectedLine ? null : closest);
  }
}

class HandLine {
  final int id;
  final String name;
  final String emoji;
  final Color color;
  final String description;
  final List<Offset> points;

  const HandLine({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.description,
    required this.points,
  });
}

class HandLinesPainter extends CustomPainter {
  final List<HandLine> lines;
  final int? selectedLine;
  final double pulseValue;

  const HandLinesPainter({
    required this.lines,
    required this.selectedLine,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final isSelected = selectedLine == line.id;
      final isOther = selectedLine != null && !isSelected;

      final opacity = isOther ? 0.35 : (isSelected ? pulseValue : 0.75);
      final strokeWidth = isSelected ? 4.0 : 2.5;

      final paint = Paint()
        ..color = line.color.withOpacity(opacity)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      // Glow efekti seçili çizgi için
      if (isSelected) {
        final glowPaint = Paint()
          ..color = line.color.withOpacity(0.25 * pulseValue)
          ..strokeWidth = 10.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..style = PaintingStyle.stroke;
        _drawLine(canvas, size, line.points, glowPaint);
      }

      _drawLine(canvas, size, line.points, paint);

      // Nokta işaretçiler
      final dotPaint = Paint()
        ..color = line.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      for (final pt in line.points) {
        final center = Offset(pt.dx * size.width, pt.dy * size.height);
        canvas.drawCircle(center, isSelected ? 4.0 : 2.5, dotPaint);
      }
    }
  }

  void _drawLine(Canvas canvas, Size size, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path();
    path.moveTo(points[0].dx * size.width, points[0].dy * size.height);
    for (int i = 1; i < points.length - 1; i++) {
      final p1 = Offset(points[i].dx * size.width, points[i].dy * size.height);
      final p2 = Offset(points[i + 1].dx * size.width, points[i + 1].dy * size.height);
      path.quadraticBezierTo(p1.dx, p1.dy, (p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    }
    final last = points.last;
    path.lineTo(last.dx * size.width, last.dy * size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HandLinesPainter old) =>
      old.selectedLine != selectedLine || old.pulseValue != pulseValue;
}
