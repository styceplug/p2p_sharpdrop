import 'package:flutter/material.dart';
import 'package:p2p_sharpdrop/widgets/snackbars.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final String supportEmail = 'support@yourapp.com';
  final String whatsappNumber = '2348140920578'; // Use international format without +

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=P2P Sharp Drop App Support&body=Hello, I need help with...',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email client.')),
      );
    }
  }

  void _launchWhatsApp() async {
    final Uri whatsappUrl = Uri.parse('https://wa.me/${whatsappNumber.replaceAll('+', '')}?text=Hello, I need help with...');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Support'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.support_agent, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Need Help?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Reach out to us through any of the support options below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed:(){MySnackBars.processing(title: 'This feature is Coming Soon', message: 'Watch this space in our coming updates');} ,
              icon: Icon(Icons.email),
              label: Text('Contact via Email'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:(){MySnackBars.processing(title: 'This feature is Coming Soon', message: 'Watch this space in our coming updates');} ,
              icon: Icon(Icons.chat),
              label: Text('Contact via WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}