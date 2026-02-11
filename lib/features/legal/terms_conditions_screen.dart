import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms & Conditions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Last updated: February 2026', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            Text('Acceptance of Terms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('By downloading and using NameSwipe, you agree to these terms and conditions.'),
            SizedBox(height: 16),
            Text('Use of the App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('NameSwipe is a baby name discovery app. The names and meanings provided are for '
                'informational purposes only. We strive for accuracy but cannot guarantee that all '
                'name meanings and origins are 100% accurate.'),
            SizedBox(height: 16),
            Text('Intellectual Property', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('The app design, code, and branding are the property of the developer. '
                'Baby names themselves are part of the public domain.'),
            SizedBox(height: 16),
            Text('Disclaimer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('The app is provided "as is" without warranties of any kind. '
                'We are not responsible for any decisions made based on the information in this app.'),
            SizedBox(height: 16),
            Text('Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('We reserve the right to modify these terms at any time. '
                'Continued use of the app constitutes acceptance of updated terms.'),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
