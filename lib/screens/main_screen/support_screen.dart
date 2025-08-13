import 'package:flutter/material.dart';
import 'package:p2p_sharpdrop/widgets/snackbars.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/dimensions.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final String supportEmail = 'support@sharpdropapp.com';
  final String whatsappNumber = '2347083666085';
  final String callNumber = '02013309563';

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query:
          'subject=B2C Sharp Drop App Support&body=Hello, I need help with...',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email client.')),
      );
    }
  }

  void _launchWhatsapp() async {
    final Uri url = Uri.parse('https:wa.me/$whatsappNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the website.')),
      );
    }
  }

  Future<void> openDialer() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: callNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not open dialer for $whatsappNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Support'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: Padding(
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
                onPressed: _launchEmail,
                icon: Icon(Icons.email),
                label: Text('Contact via Email'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _launchWhatsapp();
                      },
                      icon: Icon(Icons.chat),
                      label: Text('Reach out to us'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.width10),
                  IntrinsicWidth(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        openDialer();
                      },
                      icon: Icon(Icons.call),
                      label: Text('Call us'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
