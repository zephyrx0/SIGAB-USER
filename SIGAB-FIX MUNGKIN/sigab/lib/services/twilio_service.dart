import 'package:http/http.dart' as http;
import 'dart:convert';

class TwilioService {
  static const String accountSid = 'AC902e39eb87780add427ec26b92f36051';
  static const String authToken = '7f9d1eb9a9073f9d15551b8c05bba23f';
  static const String twilioNumber =
      'whatsapp:+14155238886'; // Your Twilio WhatsApp number

  static Future<bool> sendWhatsAppMessage({
    required String to,
    required String message,
  }) async {
    try {
      final url = Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

      final response = await http.post(
        url,
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': twilioNumber,
          'To': 'whatsapp:+$to',
          'Body': message,
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Twilio API Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
      return false;
    }
  }

  static String generateOTP() {
    // Generate a 6-digit OTP
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();
  }
}
