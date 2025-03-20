import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentiment Analysis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SentimentAnalyzer(),
    );
  }
}

class SentimentAnalyzer extends StatefulWidget {
  const SentimentAnalyzer({Key? key}) : super(key: key);

  @override
  _SentimentAnalyzerState createState() => _SentimentAnalyzerState();
}

class _SentimentAnalyzerState extends State<SentimentAnalyzer> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  // API key
  final String apiKey = 'AIzaSyD-C0StV-RJLWVb6si3mVhPbtwVJ8OAR-w';

  // Màu sắc và emoji dựa trên cảm xúc
  Color _backgroundColor = Colors.white; // Trạng thái ban đầu là trắng
  String _emojiDisplay = '😐'; // Emoji trung tính

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyzeSentiment() async {
    final text = _textController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a sentence')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Khởi tạo model Gemini
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // Sử dụng mô hình mới nhất
        apiKey: apiKey,
      );

      // Tạo prompt yêu cầu phân tích sentiment
      final prompt =
          'Analyze the sentiment of this text and respond with only "positive", "negative", or "neutral": "$text"';

      // Gửi yêu cầu đến API
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      // Lấy kết quả
      final responseText = response.text?.toLowerCase() ?? 'neutral';
      if (responseText.isEmpty) {
        setState(() {
          _backgroundColor = Colors.grey;
          _emojiDisplay = '😐';
          _isLoading = false;
        });
        return;
      }

      // Phân tích kết quả
      if (responseText.contains('positive')) {
        setState(() {
          _backgroundColor = Colors.green;
          _emojiDisplay = '😀';
          _isLoading = false;
        });
      } else if (responseText.contains('negative')) {
        setState(() {
          _backgroundColor = const Color(0xFFB71C1C); // Đỏ đậm
          _emojiDisplay = '😞';
          _isLoading = false;
        });
      } else {
        setState(() {
          _backgroundColor = Colors.grey;
          _emojiDisplay = '😐';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _backgroundColor = Colors.grey;
        _emojiDisplay = '😐';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Top bar with "Sentiment" text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Center(
                  child: Text(
                    'Sentiment',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text input field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Enter text to analyze',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _analyzeSentiment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Emoji display
                      _isLoading
                          ? CircularProgressIndicator(
                        color: _backgroundColor == Colors.green
                            ? Colors.black
                            : Colors.white,
                      )
                          : Text(
                        _emojiDisplay,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}