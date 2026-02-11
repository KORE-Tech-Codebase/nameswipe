import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Last updated: February 2026', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            Text('Information We Collect', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('NameSwipe is designed with your privacy in mind. We do not collect personal information. '
                'All your favorites and swipe history are stored locally on your device.'),
            SizedBox(height: 16),
            Text('Data Storage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('All data is stored locally on your device using SQLite database. '
                'We do not transmit your personal data to any external servers. '
                'The app connects to our API solely to download baby name data.'),
            SizedBox(height: 16),
            Text('Advertising', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('This app may display advertisements provided by Google AdMob. '
                'AdMob may collect certain device information to serve relevant ads. '
                'Please refer to Google\'s privacy policy for more details.'),
            SizedBox(height: 16),
            Text('Third-Party Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('The app uses the following third-party services:\n'
                '- Google AdMob (advertising)\n'
                '- Names API (baby name data)\n\n'
                'Each of these services has their own privacy policy.'),
            SizedBox(height: 16),
            Text('Changes to This Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('We may update this privacy policy from time to time. '
                'Any changes will be reflected in the app.'),
            SizedBox(height: 16),
            Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('If you have questions about this privacy policy, please contact us through the app store listing.'),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
