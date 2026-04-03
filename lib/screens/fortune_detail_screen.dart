import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_theme.dart';
import '../services/ai_service.dart';
import '../services/diamond_service.dart';
import '../widgets/shop_bottom_sheet.dart';
import '../widgets/hand_lines_overlay.dart';

class FortuneDetailScreen extends StatefulWidget {
  final FortuneType type;
  const FortuneDetailScreen({super.key, required this.type});

  @override
  State<FortuneDetailScreen> createState() => _FortuneDetailScreenState();
}

class _FortuneDetailScreenState extends State<FortuneDetailScreen> {
  final _questionCtrl = TextEditingController();
  final _picker = ImagePicker();

  List<File> _images = [];
  String? _result;
  bool _isLoading = false;
  bool _isValidating = false;
  String? _validationError;

  // Tarot
  List<String> _selectedTarotCards = [];
  final _tarotCards = [
    'Sihirbaz 🧙','Yüksek Rahibe 🌙','İmparatoriçe 👑','İmparator ⚔️',
    'Hierofant 📿','Aşıklar 💕','Savaş Arabası 🏆','Adalet ⚖️','Ermiş 🕯️',
    'Kader Çarkı ☯️','Güç 🦁','Asılı Adam 🌀','Ölüm 🦋','Denge ⚗️',
    'Şeytan 🔥','Kule ⚡','Yıldız ⭐','Ay 🌕','Güneş ☀️','Yargı 🎺','Dünya 🌍','Aptal 🌸',
  ];

  // İskambil
  List<String> _selectedPlayingCards = [];
  final _suits = ['♠','♥','♦','♣'];
  final _values = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];

  // Renk
  List<String> _selectedColors = [];
  final _colors = [
    {'name':'Kırmızı','color':Colors.red},
    {'name':'Mavi','color':Colors.blue},
    {'name':'Yeşil','color':Colors.green},
    {'name':'Sarı','color':Colors.yellow},
    {'name':'Mor','color':Colors.purple},
    {'name':'Turuncu','color':Colors.orange},
    {'name':'Pembe','color':Colors.pink},
    {'name':'Beyaz','color':Colors.white},
    {'name':'Siyah','color':Colors.grey.shade900},
    {'name':'Turkuaz','color':Colors.teal},
    {'name':'Altın','color':const Color(0xFFC9A84C)},
    {'name':'Gümüş','color':Colors.blueGrey},
  ];

  // Çin
  String? _selectedAnimal;
  final _chineseAnimals = [
    '🐭 Fare','🐮 Öküz','🐯 Kaplan','🐰 Tavşan','🐲 Ejder',
    '🐍 Yılan','🐴 At','🐐 Keçi','🐵 Maymun','🐓 Horoz','🐶 Köpek','🐷 Domuz',
  ];
  final _birthYearCtrl = TextEditingController();

  // Aşk
  final _name1Ctrl = TextEditingController();
  final _name2Ctrl = TextEditingController();

  // Yıldızname
  final _birthDateCtrl = TextEditingController();
  final _birthTimeCtrl = TextEditingController();
  final _birthPlaceCtrl = TextEditingController();

  static const Map<FortuneType, Map<String, dynamic>> _fortunes = {
    FortuneType.coffee:   {'emoji':'☕','title':'Kahve Falı',    'subtitle':'YZ fincanınızdaki desenleri analiz eder'},
    FortuneType.tarot:    {'emoji':'🃏','title':'Tarot Falı',    'subtitle':'3 kart seç, kaderini öğren'},
    FortuneType.hand:     {'emoji':'🖐','title':'El Falı',       'subtitle':'YZ eldeki her çizgiyi analiz eder'},
    FortuneType.face:     {'emoji':'🪞','title':'Yüz Falı',      'subtitle':'Yüz hatlarından kader ve enerji analizi'},
    FortuneType.dream:    {'emoji':'🌙','title':'Rüya Yorumu',   'subtitle':'Rüyanızın gizli mesajlarını öğrenin'},
    FortuneType.iskambil: {'emoji':'♠️','title':'İskambil Falı', 'subtitle':'5 kart seçin, mesajı alın'},
    FortuneType.love:     {'emoji':'💕','title':'Aşk Falı',      'subtitle':'Aşk uyumunuzu keşfedin'},
    FortuneType.color:    {'emoji':'🎨','title':'Renk Falı',     'subtitle':'Renk seçiminiz ruhunuzu yansıtır'},
    FortuneType.chinese:  {'emoji':'🐉','title':'Çin Falı',      'subtitle':'Doğunun kadim bilgeliğiyle'},
    FortuneType.water:    {'emoji':'💧','title':'Su Falı',       'subtitle':'Suyun saf enerjisiyle niyetini oku'},
    FortuneType.star:     {'emoji':'⭐','title':'Yıldızname',    'subtitle':'Doğum haritanla geleceğini keşfet'},
  };

  @override
  void dispose() {
    _questionCtrl.dispose();
    _birthYearCtrl.dispose();
    _birthDateCtrl.dispose();
    _birthTimeCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _name1Ctrl.dispose();
    _name2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isEmpty) return;

    final files = images.map((x) => File(x.path)).toList();

    // Görsel validasyon (kahve, el, yüz için)
    final needsValidation = widget.type == FortuneType.coffee ||
        widget.type == FortuneType.hand ||
        widget.type == FortuneType.face;

    if (needsValidation && files.isNotEmpty) {
      setState(() { _isValidating = true; _validationError = null; });
      final result = await AIService.instance.validateImage(
        image: files.first,
        type: widget.type,
      );
      setState(() { _isValidating = false; });

      if (!result.isValid) {
        setState(() { _validationError = result.message; });
        _showSnack('⚠️ ${result.message}');
        return;
      }
    }

    setState(() { _images = files; _validationError = null; });
  }

  Future<void> _pickSingleImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image == null) return;
    final file = File(image.path);

    setState(() { _isValidating = true; _validationError = null; });
    final result = await AIService.instance.validateImage(
      image: file,
      type: widget.type,
    );
    setState(() { _isValidating = false; });

    if (!result.isValid) {
      setState(() { _validationError = result.message; });
      _showSnack('⚠️ ${result.message}');
      return;
    }
    setState(() { _images = [file]; _validationError = null; });
  }

  Future<void> _askFortune() async {
    // Validasyon
    if ((widget.type == FortuneType.coffee || widget.type == FortuneType.hand) &&
        _images.length < 2) {
      _showSnack('⚠️ En az 2 fotoğraf yüklemelisiniz!');
      return;
    }
    if (widget.type == FortuneType.face && _images.isEmpty) {
      _showSnack('⚠️ Yüz fotoğrafı yüklemelisiniz!');
      return;
    }
    if (widget.type == FortuneType.tarot && _selectedTarotCards.length < 3) {
      _showSnack('⚠️ En az 3 kart seçin!');
      return;
    }
    if (widget.type == FortuneType.iskambil && _selectedPlayingCards.length < 3) {
      _showSnack('⚠️ En az 3 kart seçin!');
      return;
    }
    if (widget.type == FortuneType.color && _selectedColors.isEmpty) {
      _showSnack('⚠️ Lütfen renk seçin!');
      return;
    }
    if (widget.type == FortuneType.star && _birthDateCtrl.text.isEmpty) {
      _showSnack('⚠️ Doğum tarihinizi girin!');
      return;
    }
    if (widget.type == FortuneType.water && _questionCtrl.text.isEmpty) {
      _showSnack('⚠️ Niyetinizi yazın!');
      return;
    }

    // Elmas kontrolü
    if (DiamondService.instance.diamonds < DiamondService.fortuneCost) {
      ShopBottomSheet.show(context);
      return;
    }

    setState(() { _isLoading = true; _result = null; });

    final spent = await DiamondService.instance.spend(DiamondService.fortuneCost);
    if (!spent) {
      setState(() => _isLoading = false);
      ShopBottomSheet.show(context);
      return;
    }

    final extra = <String, dynamic>{};
    if (widget.type == FortuneType.tarot)   extra['cards'] = _selectedTarotCards;
    if (widget.type == FortuneType.iskambil) extra['cards'] = _selectedPlayingCards;
    if (widget.type == FortuneType.color)    extra['colors'] = _selectedColors;
    if (widget.type == FortuneType.chinese) {
      extra['animal'] = _selectedAnimal ?? '';
      extra['year'] = _birthYearCtrl.text;
    }
    if (widget.type == FortuneType.love) {
      extra['name1'] = _name1Ctrl.text;
      extra['name2'] = _name2Ctrl.text;
    }
    if (widget.type == FortuneType.star) {
      extra['birthDate'] = _birthDateCtrl.text;
      extra['birthTime'] = _birthTimeCtrl.text;
      extra['birthPlace'] = _birthPlaceCtrl.text;
    }

    final result = await AIService.instance.getFortune(
      type: widget.type,
      question: _questionCtrl.text,
      images: _images,
      extra: extra,
    );

    setState(() { _result = result; _isLoading = false; });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.deepBg3,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _fortunes[widget.type]!;
    return Scaffold(
      backgroundColor: AppTheme.deepBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${info['emoji']} ${info['title']}',
              style: const TextStyle(fontFamily: 'Cinzel', color: AppTheme.gold, fontSize: 16),
            ),
            Text(
              info['subtitle'],
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontFamily: 'Nunito'),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.gold, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppTheme.deepBg.withOpacity(0.9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSpecificUI(),
            const SizedBox(height: 16),
            // Su falı niyet alanı yerine sadece soru alanı yeterli
            if (widget.type != FortuneType.star) _buildQuestionField(),
            if (_isValidating) _buildValidatingIndicator(),
            if (_validationError != null) _buildValidationError(),
            if (_isLoading) _buildLoading(),
            if (_result != null) _buildResult(),
            const SizedBox(height: 16),
            _buildAskButton(),
            _buildCostInfo(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificUI() {
    switch (widget.type) {
      case FortuneType.coffee:
        return _buildImageUpload(
          label: '📸 Fincan fotoğrafı yükleyin (en az 2 açıdan)',
          icon: '☕',
          hint: '2+ farklı açıdan çekin',
        );
      case FortuneType.hand:
        return _buildHandUI();
      case FortuneType.face:
        return _buildFaceUI();
      case FortuneType.tarot:
        return _buildTarotSelector();
      case FortuneType.iskambil:
        return _buildPlayingCardSelector();
      case FortuneType.color:
        return _buildColorSelector();
      case FortuneType.chinese:
        return _buildChineseSelector();
      case FortuneType.love:
        return _buildLoveInputs();
      case FortuneType.water:
        return _buildWaterUI();
      case FortuneType.star:
        return _buildStarUI();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── EL FALI — renkli çizgi overlay ────────────────────────────────────────
  Widget _buildHandUI() {
    if (_images.isNotEmpty) {
      return HandLinesOverlay(image: _images.first);
    }
    return _buildImageUpload(
      label: '📸 El fotoğrafı yükleyin (avuç içi, 2 adet)',
      icon: '🖐',
      hint: 'Sağ ve sol el, avuç içi görünür',
    );
  }

  // ─── YÜZ FALI ───────────────────────────────────────────────────────────────
  Widget _buildFaceUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🪞 Selfie veya portre fotoğrafı yükleyin',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        if (_images.isEmpty)
          Row(
            children: [
              Expanded(
                child: _imagePickButton(
                  icon: '📷',
                  label: 'Kamera',
                  onTap: _pickSingleImage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _imagePickButton(
                  icon: '🖼️',
                  label: 'Galeri',
                  onTap: _pickImages,
                ),
              ),
            ],
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 0.85,
                  child: Image.file(_images.first, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _images = []),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _imagePickButton({required String icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          borderRadius: BorderRadius.circular(14),
          color: AppTheme.cardBg,
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ─── SU FALI ────────────────────────────────────────────────────────────────
  Widget _buildWaterUI() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0D47A1).withOpacity(0.2), const Color(0xFF1565C0).withOpacity(0.1)],
        ),
        border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text('💧', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          const Text(
            'Niyetinizi kalben hissederek yazın.\nSu, enerjinizi okuyacak.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _questionCtrl,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Örn: Yeni bir başlangıç yapmaya hazır mıyım?',
              hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              filled: true,
              fillColor: AppTheme.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF42A5F5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── YILDIZNAME ─────────────────────────────────────────────────────────────
  Widget _buildStarUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⭐ Doğum bilgilerinizi girin',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _styledTextField(_birthDateCtrl, '📅 Doğum tarihi', 'GG/AA/YYYY'),
        const SizedBox(height: 10),
        _styledTextField(_birthTimeCtrl, '🕐 Doğum saati (isteğe bağlı)', 'SS:DD'),
        const SizedBox(height: 10),
        _styledTextField(_birthPlaceCtrl, '📍 Doğum yeri (isteğe bağlı)', 'İstanbul, Türkiye'),
        const SizedBox(height: 10),
        _styledTextField(_questionCtrl, '💬 Sorunuz (isteğe bağlı)', 'Bu yıl benim için ne var?', maxLines: 2),
      ],
    );
  }

  Widget _styledTextField(
    TextEditingController ctrl,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        filled: true,
        fillColor: AppTheme.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.gold)),
      ),
    );
  }

  // ─── ORTAK GÖRSEL YÜKLEME ────────────────────────────────────────────────────
  Widget _buildImageUpload({required String label, required String icon, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(
                color: _images.isEmpty ? AppTheme.cardBorder : AppTheme.gold.withOpacity(0.5),
                width: _images.isEmpty ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
              color: AppTheme.cardBg,
            ),
            child: _images.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        const Text('Fotoğraf yükle', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Text(hint, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 1, crossAxisSpacing: 8, mainAxisSpacing: 8,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_images[i], fit: BoxFit.cover),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ─── TAROT ──────────────────────────────────────────────────────────────────
  Widget _buildTarotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🃏 3 kart seçin', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _tarotCards.map((card) {
            final sel = _selectedTarotCards.contains(card);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (sel) _selectedTarotCards.remove(card);
                  else if (_selectedTarotCards.length < 3) _selectedTarotCards.add(card);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.gold.withOpacity(0.15) : AppTheme.cardBg,
                  border: Border.all(color: sel ? AppTheme.gold : AppTheme.cardBorder),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(card, style: TextStyle(fontSize: 12, color: sel ? AppTheme.gold : AppTheme.textSecondary)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── İSKAMBİL ───────────────────────────────────────────────────────────────
  Widget _buildPlayingCardSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('♠️ 5 kart seçin', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: List.generate(12, (i) {
            final suit = _suits[i % 4];
            final val = _values[i ~/ 1 % 13];
            final card = '$val$suit';
            final sel = _selectedPlayingCards.contains(card);
            final isRed = suit == '♥' || suit == '♦';
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (sel) _selectedPlayingCards.remove(card);
                  else if (_selectedPlayingCards.length < 5) _selectedPlayingCards.add(card);
                });
              },
              child: Container(
                width: 48, height: 64,
                decoration: BoxDecoration(
                  color: sel ? AppTheme.gold.withOpacity(0.1) : Colors.white,
                  border: Border.all(color: sel ? AppTheme.gold : Colors.grey.shade300, width: sel ? 2 : 1),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Center(
                  child: Text(card, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isRed ? Colors.red : Colors.black87)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── RENK ───────────────────────────────────────────────────────────────────
  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🎨 İlk aklınıza gelen 3 rengi seçin', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: _colors.length,
          itemBuilder: (_, i) {
            final c = _colors[i];
            final sel = _selectedColors.contains(c['name']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (sel) _selectedColors.remove(c['name']);
                  else if (_selectedColors.length < 3) _selectedColors.add(c['name'] as String);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: c['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 2.5),
                  boxShadow: sel ? [const BoxShadow(color: Colors.white30, blurRadius: 8, spreadRadius: 1)] : null,
                ),
              ),
            );
          },
        ),
        if (_selectedColors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('✓ Seçilenler: ${_selectedColors.join(', ')}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ),
      ],
    );
  }

  // ─── ÇİN ────────────────────────────────────────────────────────────────────
  Widget _buildChineseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🐾 Doğum hayvanınızı seçin', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: _chineseAnimals.length,
          itemBuilder: (_, i) {
            final sel = _selectedAnimal == _chineseAnimals[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedAnimal = _chineseAnimals[i]),
              child: Container(
                decoration: BoxDecoration(
                  color: sel ? AppTheme.gold.withOpacity(0.1) : AppTheme.cardBg,
                  border: Border.all(color: sel ? AppTheme.gold : AppTheme.cardBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_chineseAnimals[i].split(' ')[0], style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(_chineseAnimals[i].split(' ')[1], style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _birthYearCtrl,
          style: const TextStyle(color: AppTheme.textPrimary),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '📅 Doğum yılınız',
            labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            filled: true,
            fillColor: AppTheme.cardBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.gold)),
          ),
        ),
      ],
    );
  }

  // ─── AŞK ────────────────────────────────────────────────────────────────────
  Widget _buildLoveInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('👤 İsimlerinizi girin', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _loveTextField(_name1Ctrl, 'Senin adın')),
            const SizedBox(width: 10),
            Expanded(child: _loveTextField(_name2Ctrl, 'Sevgilinin adı')),
          ],
        ),
      ],
    );
  }

  Widget _loveTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        filled: true,
        fillColor: AppTheme.cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE91E8C))),
      ),
    );
  }

  // ─── SORU ALANI ─────────────────────────────────────────────────────────────
  Widget _buildQuestionField() {
    // Su falında zaten niyet alanı var
    if (widget.type == FortuneType.water) return const SizedBox.shrink();

    final hint = widget.type == FortuneType.face
        ? 'Örn: Kişiliğim ve enerjim hakkında ne görüyorsun?'
        : 'Örn: Yakında hayatımda büyük değişimler olacak mı?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('💬 Sorunuzu yazın (isteğe bağlı)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: _questionCtrl,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            filled: true,
            fillColor: AppTheme.cardBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.gold)),
          ),
        ),
      ],
    );
  }

  // ─── DURUM GÖSTERGELERİ ─────────────────────────────────────────────────────
  Widget _buildValidatingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold)),
          SizedBox(width: 10),
          Text('Fotoğraf kontrol ediliyor...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildValidationError() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _validationError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.purple.withOpacity(0.1), AppTheme.gold.withOpacity(0.05)]),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 2),
          SizedBox(height: 12),
          Text('Mistik enerji okunuyor...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.purple.withOpacity(0.1), AppTheme.gold.withOpacity(0.05)]),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✦ Falınız ✦', style: TextStyle(fontFamily: 'Cinzel', color: AppTheme.gold, fontSize: 14)),
          const SizedBox(height: 12),
          Text(_result!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.8)),
        ],
      ),
    );
  }

  Widget _buildAskButton() {
    final info = _fortunes[widget.type]!;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || _isValidating ? null : _askFortune,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
          foregroundColor: const Color(0xFF1A1000),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          '✦ ${info['title']} • 💎 50',
          style: const TextStyle(fontFamily: 'Cinzel', fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildCostInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💎 ', style: TextStyle(fontSize: 13)),
          Text(
            'Hesabınızdan ${DiamondService.fortuneCost} elmas düşülecek (Bakiye: ${DiamondService.instance.diamonds})',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
