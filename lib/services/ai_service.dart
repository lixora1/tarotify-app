import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Anthropic Claude API — Tüm fal türleri için YZ motoru
class AIService {
  AIService._();
  static final AIService instance = AIService._();

static const String _backendUrl = 'https://tarotify-backend-production.up.railway.app/api/fortune';
static const String _validateUrl = 'https://tarotify-backend-production.up.railway.app/api/validate';

  /// Görsel validasyon — yanlış fotoğraf yüklenirse uyar
  Future<ImageValidationResult> validateImage({
    required File image,
    required FortuneType type,
  }) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Data = base64Encode(bytes);
      final ext = image.path.split('.').last.toLowerCase();
      final mediaType = ext == 'png' ? 'image/png' : 'image/jpeg';

      String expectedContent;
      switch (type) {
        case FortuneType.coffee:
          expectedContent = 'Türk kahvesi fincanı (dibe çevrilmiş, içinde telve desenleri olan)';
          break;
        case FortuneType.hand:
          expectedContent = 'insan eli (avuç içi görünür, çizgiler belli)';
          break;
        case FortuneType.face:
          expectedContent = 'insan yüzü (selfie veya portre fotoğrafı)';
          break;
        default:
          return const ImageValidationResult(isValid: true, message: '');
      }

      final content = [
        {
          'type': 'image',
          'source': {'type': 'base64', 'media_type': mediaType, 'data': base64Data},
        },
        {
          'type': 'text',
          'text': 'Bu fotoğrafta $expectedContent var mı?\nSadece şu JSON formatında cevap ver (başka hiçbir şey yazma):\n{"valid": true/false, "message": "kısa açıklama"}\nvalid=true ise mesaj boş bırak. valid=false ise Türkçe kısa açıklama yaz.',
        },
      ];

      final response = await http.post(
        Uri.parse(_validateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type': type.name, 'content': content}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = (data['result'] as String).trim();
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final parsed = jsonDecode(text.substring(jsonStart, jsonEnd + 1));
          return ImageValidationResult(
            isValid: parsed['valid'] == true,
            message: parsed['message'] ?? '',
          );
        }
      }
      return const ImageValidationResult(isValid: true, message: '');
    } catch (_) {
      return const ImageValidationResult(isValid: true, message: '');
    }
  }

  /// Fal yorumu al
  Future<String> getFortune({
    required FortuneType type,
    required String question,
    List<File>? images,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final prompt = _buildPrompt(type, question, extra);

      List<Map<String, dynamic>> imageContent = [];
      if (images != null && images.isNotEmpty) {
        for (final img in images) {
          final bytes = await img.readAsBytes();
          final base64Data = base64Encode(bytes);
          final ext = img.path.split('.').last.toLowerCase();
          final mediaType = ext == 'png' ? 'image/png' : 'image/jpeg';
          imageContent.add({
            'type': 'image',
            'source': {'type': 'base64', 'media_type': mediaType, 'data': base64Data},
          });
        }
      }

      final content = [
        ...imageContent,
        {'type': 'text', 'text': prompt},
      ];

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type': type.name, 'content': content}),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] as String;
      } else {
        throw Exception('API Error: \${response.statusCode}');
      }
    } catch (e) {
      return _fallbackResponse(type);
    }
  }

  String _buildPrompt(FortuneType type, String question, Map<String, dynamic>? extra) {
    final q = question.isEmpty ? 'Genel bir yorum yap' : question;

    switch (type) {
      case FortuneType.coffee:
        return 'Sen uzman bir Türk kahvesi falı okuyucususun.\nKullanıcının yüklediği fincan fotoğraflarını analiz et.\nSoru: "$q"\n\nFincanın içindeki desenleri, şekilleri ve sembolleri detaylıca yorumla:\n• Fincan dibindeki desenler ve anlamları\n• Kenarlardaki figürler (insan, hayvan, nesne)\n• Özel semboller (kalp, yıldız, yol, dağ vb.)\n• Yakın gelecek (1-3 ay) mesajları\n• Uzak gelecek mesajları\n• Genel tavsiyeler\n\nMistik, sıcak ve içten bir Türkçe dil kullan. 4-5 paragraf.';

      case FortuneType.hand:
        return 'Sen uzman bir el falı okuyucususun (kiromant).\nKullanıcının yüklediği el fotoğraflarını analiz et.\nSoru: "$q"\n\nHer çizgiyi detaylıca yorumla:\n🖐 Yaşam çizgisi — sağlık, enerji, uzun ömür\n❤️ Kalp çizgisi — aşk, ilişkiler, duygusal dünya\n🧠 Kafa çizgisi — zeka, karar verme, düşünce yapısı\n⭐ Kader çizgisi — kariyer, başarı yolculuğu\n☀️ Güneş çizgisi — yaratıcılık, şöhret, maddi başarı\nParmak uzunlukları ve el şeklinin anlamları\n\nDetaylı, mistik ve bilge bir Türkçe dil kullan. 5-6 paragraf.';

      case FortuneType.face:
        return 'Sen uzman bir yüz falı okuyucususun (fizyognomi uzmanı).\nKullanıcının yüklediği yüz fotoğrafını analiz et.\nSoru: "$q"\n\nYüzün her bölümünü mistik ve karakterolojik açıdan yorumla:\n👁 Gözler — ruhun aynası, içsel dünya, gizli güçler\n👃 Burun — güç, irade ve yaşam enerjisi\n👄 Dudaklar — iletişim, tutku ve duygusal ifade\n🌟 Alın — zeka, liderlik ve kaderin yazıldığı yer\n🦋 Yanak kemikleri ve çene yapısı — kararlılık ve hayat yolculuğu\n✨ Genel yüz enerjisi ve aura rengi\n🔮 Bu kişinin özel yetenekleri ve yaşamdaki misyonu\n\nGüven verici, mistik ve aydınlatıcı Türkçe. 5-6 paragraf.';

      case FortuneType.water:
        return 'Sen uzman bir su falı ve durugörü okuyucususun.\nKullanıcının niyeti: "$q"\n\nSuyun saf enerjisi ve evrensel bilinç üzerinden derin bir analiz yap:\n💧 Niyetin su elementine yansıması\n🌊 Evrenin bu niyete verdiği enerjetik cevap\n🔮 Durugörü mesajları — ne görünüyor, ne hissediliyor\n⚡ Yakın gelecekte açılacak kapılar\n🌙 Dikkat edilmesi gereken enerjetik bloklar\n✨ Suyun tavsiyesi — bu dönemde nasıl akmalısın?\n🌟 Özel bir sembol veya sayı mesajı\n\nMistik, akışkan ve içten bir Türkçe dil kullan. 4-5 paragraf.';

      case FortuneType.star:
        final birthDate = extra?['birthDate'] as String? ?? '';
        final birthTime = extra?['birthTime'] as String? ?? 'bilinmiyor';
        final birthPlace = extra?['birthPlace'] as String? ?? 'bilinmiyor';
        return 'Sen uzman bir astroloji ve yıldızname okuyucususun.\nDoğum tarihi: $birthDate\nDoğum saati: $birthTime\nDoğum yeri: $birthPlace\nSoru: "$q"\n\nKapsamlı yıldızname yorumu yap:\n⭐ Güneş burcu — temel kimlik ve yaşam amacı\n🌙 Ay burcu — duygusal dünya ve içsel ihtiyaçlar\n⬆️ Yükselen burç — dışa yansıyan kişilik\n🔴 Mars — eylem gücü, tutku ve enerji\n💰 Venüs — aşk dili, estetik anlayış ve maddi şans\n🧠 Merkür — iletişim tarzı ve zihinsel yapı\n🪐 Bu dönemde etkili olan gezegenler\n🔮 Önümüzdeki 3 ay için yıldız haritası\n\nBilge, detaylı ve aydınlatıcı Türkçe. 5-6 paragraf.';

      case FortuneType.tarot:
        final cards = extra?['cards'] as List<String>? ?? [];
        return 'Sen deneyimli bir tarot okuyucususun.\nSeçilen kartlar: ${cards.join(", ")}\nSoru: "$q"\n\nÜç kartlık yayılım yorumu yap (geçmiş - şimdiki an - gelecek):\n• Her kartın sembolik anlamı\n• Kartlar arası enerji akışı\n• Gizli mesajlar ve uyarılar\n• Tavsiye ve eylem önerileri\n\nMistik, derin ve aydınlatıcı Türkçe. 4-5 paragraf.';

      case FortuneType.dream:
        return 'Sen uzman bir rüya yorumcususun.\nRüya: "$q"\n\nHem psikolojik hem spiritüel açıdan yorumla:\n• Rüyadaki sembollerin anlamları\n• Alt bilinç mesajları\n• Hayatına dair göstergeler\n• Uyarılar ve fırsatlar\n• Pratikte ne yapmalısın?\n\nDerin, içten, aydınlatıcı Türkçe. 4-5 paragraf.';

      case FortuneType.iskambil:
        final cards = extra?['cards'] as List<String>? ?? [];
        return 'Sen uzman bir iskambil falı okuyucususun.\nSeçilen kartlar: ${cards.join(", ")}\nSoru: "$q"\n\nHer kartın iskambil falındaki anlamını yorumla:\n• Renklerin anlamı (siyah/kırmızı)\n• Rakamların mesajları\n• Figürlerin (J, Q, K, A) sembolizmi\n• Kartların birbirini nasıl etkilediği\n• Genel mesaj ve tavsiye\n\nMistik ve sıcak Türkçe. 3-4 paragraf.';

      case FortuneType.love:
        final name1 = extra?['name1'] as String? ?? 'Sen';
        final name2 = extra?['name2'] as String? ?? 'Sevgili';
        return 'Sen uzman bir aşk falı ve numeroloji okuyucususun.\nİsimler: $name1 ve $name2\nSoru: "$q"\n\nKapsamlı aşk analizi yap:\n• İsim numerolojisi ve uyum skoru\n• Ruhsal bağlılık analizi\n• İlişkinin güçlü yanları\n• Dikkat edilmesi gereken noktalar\n• Gelecek tahminleri\n• Tavsiye\n\nRomantik, umut dolu, içten Türkçe. 4-5 paragraf.';

      case FortuneType.color:
        final colors = extra?['colors'] as List<String>? ?? [];
        return 'Sen uzman bir renk falı okuyucususun.\nSeçilen renkler: ${colors.join(", ")}\nSoru: "$q"\n\nRenklerin derin analizini yap:\n• Her rengin psikolojik anlamı\n• Kişinin iç dünyasını nasıl yansıtıyor\n• Gizli arzular ve güçler\n• Bu dönemde size ne mesaj veriyor\n• Tavsiye ve yönlendirme\n\nMistik, derin ve aydınlatıcı Türkçe. 3-4 paragraf.';

      case FortuneType.chinese:
        final animal = extra?['animal'] as String? ?? '';
        final year = extra?['year'] as String? ?? '';
        return 'Sen uzman bir Çin astrolojisi ve fal okuyucususun.\nHayvan: $animal ($year doğumlu)\nSoru: "$q"\n\nKapsamlı Çin falı yorumu yap:\n• Bu hayvan burcunun temel özellikleri\n• Bu yıl için yıldız haritası\n• Aşk ve ilişkiler\n• Kariyer ve para\n• Sağlık uyarıları\n• I Ching\'den bilgelik mesajı\n\nBilge, mistik ve aydınlatıcı Türkçe. 4-5 paragraf.';
    }
  }

  String _fallbackResponse(FortuneType type) {
    return '✦ Mistik bağlantı kuruldu ✦\n\nYıldızlar bu gün sizin için özel mesajlar taşıyor. '
        'Evrenin size gönderdiği işaretler oldukça güçlü. Yakın gelecekte beklenmedik '
        'gelişmeler kapınızı çalacak. Kalbinizin sesini dinleyin ve sezgilerinize güvenin. '
        'Bu dönem, yeni başlangıçlar için son derece elverişli bir zaman dilimine işaret ediyor.\n\n'
        '✦ Evren sizinle ✦';
  }
}

class ImageValidationResult {
  final bool isValid;
  final String message;
  const ImageValidationResult({required this.isValid, required this.message});
}

enum FortuneType { coffee, hand, face, tarot, dream, iskambil, love, color, chinese, water, star }
