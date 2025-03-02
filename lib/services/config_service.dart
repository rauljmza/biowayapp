import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfigService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String?> getPrivacyPolicyUrl() async {
    try {
      final docSnapshot = await _firestore.collection('Config').doc('config').get();
      return docSnapshot.data()?['avisoPrivacidad'] as String?;
    } catch (e) {
      print('Error al obtener la URL del aviso de privacidad: $e');
      return null;
    }
  }

  static Future<void> openPrivacyPolicy() async {
    final url = await getPrivacyPolicyUrl();
    if (url != null) {
      final uri = Uri.parse(url);
      // Intenta abrir la URL en el navegador externo.
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Si falla, usa un fallback a inAppWebView.
        print('No se pudo abrir la URL en el navegador externo, abriendo en WebView.');
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } else {
      print('La URL del aviso de privacidad es nula');
    }
  }
}
