import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../services/quote_service.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<String> _savedQuotes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedQuotes();
  }

  Future<void> _loadSavedQuotes() async {
    final quotes = await QuoteService.getSavedQuotes();
    setState(() {
      _savedQuotes = quotes;
    });
  }

  Future<void> _removeQuote(int index) async {
    await QuoteService.removeQuote(_savedQuotes[index]);
    await _loadSavedQuotes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote removed.')),
    );
  }

  void _copyToClipboard(String quote) {
    Clipboard.setData(ClipboardData(text: quote));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote copied to clipboard.')),
    );
  }

  void _shareQuote(String quote) {
    Share.share(quote);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
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
            padding: const EdgeInsets.all(16.0),
            child: _savedQuotes.isEmpty
                ? Center(
              child: Text(
                'No saved quotes yet.',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Saved Quotes",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadSavedQuotes,
                    child: ListView.builder(
                      itemCount: _savedQuotes.length,
                      itemBuilder: (context, index) {
                        final quote = _savedQuotes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Card(
                            elevation: 6,
                            color: isDark
                                ? Colors.grey[850]
                                : Colors.white.withOpacity(0.95),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                quote,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    final confirm =
                                    await showDialog<bool>(
                                      context: context,
                                      builder: (context) =>
                                          AlertDialog(
                                            title:
                                            const Text("Remove Quote"),
                                            content: const Text(
                                                "Are you sure you want to remove this quote?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, false),
                                                child:
                                                const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, true),
                                                child:
                                                const Text("Remove"),
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirm == true) {
                                      _removeQuote(index);
                                    }
                                  } else if (value == 'copy') {
                                    _copyToClipboard(quote);
                                  } else if (value == 'share') {
                                    _shareQuote(quote);
                                  }
                                },
                                icon: Icon(
                                  Icons.more_vert,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'copy',
                                    child: Text("Copy"),
                                  ),
                                  const PopupMenuItem(
                                    value: 'share',
                                    child: Text("Share"),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
