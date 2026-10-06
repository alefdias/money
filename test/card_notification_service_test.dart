import 'package:flutter_test/flutter_test.dart';
import 'package:money/services/card_notification_service.dart';

void main() {
  group('CardNotificationService Parser Tests', () {
    final service = CardNotificationService.instance;

    test('Deve parsear corretamente notificação do Nubank', () {
      final detection = service.parseNotification(
        title: 'Nubank',
        content: 'Compra aprovada no seu Nubank: R\$ 150,00 em Mercado Livre',
        packageName: 'com.nu.production',
      );

      expect(detection, isNotNull);
      expect(detection!.bankName, 'Nubank');
      expect(detection.amount, 150.0);
      expect(detection.merchant, 'Mercado Livre');
      expect(detection.suggestedCategoryId, 'others');
    });

    test('Deve detectar parcelamento quando presente na notificação', () {
      final detection = service.parseNotification(
        title: 'Nubank',
        content: 'Compra aprovada de R\$ 600,00 em 3x no Magazine Luiza',
        packageName: 'com.nu.production',
      );

      expect(detection, isNotNull);
      expect(detection!.amount, 600.0);
      expect(detection.detectedInstallments, 3);
    });

    test('Deve categorizar automaticamente alimentação e transporte', () {
      final foodDetection = service.parseNotification(
        title: 'Itaú',
        content: 'Compra aprovada no valor de R\$ 45,90 em Restaurante Fogao Mineiro',
        packageName: 'com.itau',
      );

      expect(foodDetection, isNotNull);
      expect(foodDetection!.suggestedCategoryId, 'food');

      final transportDetection = service.parseNotification(
        title: 'Banco Inter',
        content: 'Compra aprovada: R\$ 80,00 no Posto Shell',
        packageName: 'br.com.intermedium',
      );

      expect(transportDetection, isNotNull);
      expect(transportDetection!.suggestedCategoryId, 'transport');
    });

    test('Deve ignorar notificações que não são de compras ou cartões', () {
      final detection = service.parseNotification(
        title: 'WhatsApp',
        content: 'Nova mensagem de João: Olá, tudo bem?',
        packageName: 'com.whatsapp',
      );

      expect(detection, isNull);
    });
  });
}
