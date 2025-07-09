import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/quote_service.dart';

class AddQuoteScreen extends StatefulWidget {
  const AddQuoteScreen({super.key});

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isInputValid = false;

  void _addQuote() async {
    final quote = _controller.text.trim();

    if (quote.isEmpty) return;

    if (quote.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quote too long (max 200 characters).')),
      );
      return;
    }

    final existingQuotes = await QuoteService.getUserQuotes();
    if (existingQuotes.contains(quote)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quote already exists.')),
      );
      return;
    }

    await QuoteService.addUserQuote(quote);
    _controller.clear();
    setState(() => _isInputValid = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote added!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isInputValid = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
      child: Scaffold(
        body: Container(
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Add Your Own Quote",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    maxLength: 200,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Enter your quote',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.grey[850]
                          : Colors.white.withOpacity(0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                          isDark ? Colors.lightBlueAccent : Colors.blue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color:
                          isDark ? Colors.white54 : Colors.grey[600],
                        ),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _isInputValid = false);
                        },
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isInputValid ? _addQuote : null,
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Add Quote',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isInputValid
                          ? (isDark
                          ? Colors.lightGreenAccent
                          : Colors.green.shade300)
                          : Colors.grey,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _isInputValid ? 6 : 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
