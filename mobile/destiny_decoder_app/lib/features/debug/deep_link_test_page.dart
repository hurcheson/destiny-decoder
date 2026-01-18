import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Debug page to test deep linking
class DeepLinkTestPage extends StatelessWidget {
  const DeepLinkTestPage({super.key});

  Future<void> _testDeepLink(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot launch: $url')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deep Link Testing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Test Deep Links',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap a button to open a deep link. The app should navigate to the target content.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildTestCard(
            context,
            'Article: Life Seal 7',
            'destinydecoder://destinydecoder.app/articles/life-seal-7-the-seeker?ref=test123',
          ),
          
          _buildTestCard(
            context,
            'Article: Life Seal 1',
            'destinydecoder://destinydecoder.app/articles/life-seal-1-the-pioneer?ref=test456',
          ),
          
          _buildTestCard(
            context,
            'Article: Basics',
            'destinydecoder://destinydecoder.app/articles/understanding-your-life-seal?ref=testbasic',
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          const Text(
            'Copy & Test Manually',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Copy link, minimize app, paste in browser/notes, and tap to open:',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          
          _buildCopyCard(
            context,
            'destinydecoder://destinydecoder.app/articles/life-seal-7-the-seeker?ref=manual001',
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, String title, String url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          url,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _testDeepLink(context, url),
      ),
    );
  }

  Widget _buildCopyCard(BuildContext context, String url) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              url,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard!')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Link'),
            ),
          ],
        ),
      ),
    );
  }
}
