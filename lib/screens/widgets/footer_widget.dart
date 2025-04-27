import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  Future<void> _launchURL(String link) async {
    final Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $link';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.shade50,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo and App Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 26),
              const SizedBox(width: 8),
              Text(
                "HealthMate",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tagline
          const Text(
            "Your Companion in Building a Healthier Life",
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Divider(
            thickness: 1,
            color: Colors.green.shade200,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 12),

          // Contact Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.email, size: 16, color: Colors.black54),
              SizedBox(width: 6),
              Text(
                "support@healthmate.com",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Social Media Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.facebookF, size: 18),
                color: Colors.green,
                onPressed: () {
                  const facebookUrl = 'https://www.facebook.com/yourpage';
                  _launchURL(facebookUrl);
                },
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.instagram, size: 18),
                color: Colors.green,
                onPressed: () {
                  const instagramUrl = 'https://www.instagram.com/yourprofile';
                  _launchURL(instagramUrl);
                },
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.twitter, size: 18),
                color: Colors.green,
                onPressed: () {
                  const twitterUrl = 'https://twitter.com/yourprofile';
                  _launchURL(twitterUrl);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Copyright
          const Text(
            "© 2025 HealthMate • All rights reserved",
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
