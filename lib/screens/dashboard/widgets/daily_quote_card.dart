import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../utils/quotes.dart';

class DailyQuoteCard extends StatelessWidget {
  final ValueNotifier<int> manualOffset;

  const DailyQuoteCard({
    super.key,
    required this.manualOffset,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: manualOffset,
      builder: (context, offset, child) {
        final int daysSinceEpoch = DateTime.now().difference(DateTime(1970)).inDays;
        final int quoteIndex = (daysSinceEpoch + offset) % Quotes.dailyQuotes.length;
        final String todayQuote = Quotes.dailyQuotes[quoteIndex];

        return GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.format_quote, color: Colors.orangeAccent, size: 28),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Daily Motivation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      manualOffset.value++;
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        'Show Another',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '"$todayQuote"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
