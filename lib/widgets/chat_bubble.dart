import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isLoading;
  final List<String>? options;
  final Function(String)? onOptionSelected;

  const ChatBubble({
    super.key,
    required this.content,
    required this.isUser,
    this.isLoading = false,
    this.options,
    this.onOptionSelected,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 48 : 12,
        right: isUser ? 12 : 48,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isLoading
                ? _buildLoadingIndicator()
                : _buildContent(context),
          ),
          if (options != null && options!.isNotEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options!.map((option) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onOptionSelected?.call(option),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(content, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final spans = <InlineSpan>[];

    // Regex to match URLs and bold text
    final urlRegex = RegExp(r'https?://[^\s]+');
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');

    int lastEnd = 0;
    String remaining = content;

    while (remaining.isNotEmpty) {
      final urlMatch = urlRegex.firstMatch(remaining);
      final boldMatch = boldRegex.firstMatch(remaining);

      // Find which match comes first
      int? urlStart = urlMatch?.start;
      int? boldStart = boldMatch?.start;

      if (urlStart == null && boldStart == null) {
        // No more matches, add remaining text
        spans.add(TextSpan(text: remaining));
        break;
      }

      // Determine which match comes first
      bool isUrlFirst =
          urlStart != null && (boldStart == null || urlStart < boldStart);

      if (isUrlFirst && urlMatch != null) {
        // Add text before URL
        if (urlMatch.start > 0) {
          spans.add(TextSpan(text: remaining.substring(0, urlMatch.start)));
        }

        // Add clickable URL
        final url = urlMatch.group(0)!;
        spans.add(
          TextSpan(
            text: '🔗 Apri link',
            style: const TextStyle(
              color: Color(0xFFD4AF37), // Gold color
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(url),
          ),
        );

        remaining = remaining.substring(urlMatch.end);
      } else if (boldMatch != null) {
        // Add text before bold
        if (boldMatch.start > 0) {
          spans.add(TextSpan(text: remaining.substring(0, boldMatch.start)));
        }

        // Add bold text
        spans.add(
          TextSpan(
            text: boldMatch.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );

        remaining = remaining.substring(boldMatch.end);
      }
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: content));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
        children: spans,
      ),
    );
  }
}
