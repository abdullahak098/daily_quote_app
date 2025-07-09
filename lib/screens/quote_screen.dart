import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/quote_service.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String _quote = 'Tap the button below to get inspired!';

  void _getNewQuote() async {
    final quote = await QuoteService.getRandomQuote();
    setState(() {
      _quote = quote;
    });
  }


  void _saveQuote() {
    QuoteService.saveQuote(_quote);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote Saved!')),
    );
  }

  void _shareQuote() {
    Share.share(_quote);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey.shade900, Colors.black]
              : [Colors.white, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: isDark ? Colors.grey[850] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Text(
                  _quote,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildCustomButton(
                  icon: Icons.refresh,
                  label: "New",
                  bgColor: isDark ? Colors.lightBlueAccent : Colors.blue.shade300,
                  textColor: Colors.black,
                  onPressed: _getNewQuote,
                ),
                _buildCustomButton(
                  icon: Icons.bookmark,
                  label: "Save",
                  bgColor: isDark ? Colors.lightGreenAccent : Colors.green.shade300,
                  textColor: Colors.black,
                  onPressed: _saveQuote,
                ),
                _buildCustomButton(
                  icon: Icons.share,
                  label: "Share",
                  bgColor: isDark ? Colors.purpleAccent.shade100 : Colors.purple.shade200,
                  textColor: Colors.black,
                  onPressed: _shareQuote,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
    );
  }
}
