import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyBzI7z9N0bM89Tci_g_1GvtKvOKM_l2JR8';
  static GenerativeModel? _model;

  // Initialize the Gemini model
  static void initialize() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
  }

  // Get AI response for financial/investment questions
  static Future<String> getFinancialAdvice(String userMessage) async {
    if (_model == null) {
      initialize();
    }

    try {
      final prompt =
          '''
You are a friendly AI financial mentor for the Finx app, a gamified stock trading simulation app. 
Your role is to help users learn about investing, trading, and financial literacy in a fun and educational way.

Context:
- This is a SIMULATION app where users trade with virtual money
- Users are learning about investing and financial markets
- Keep responses concise, helpful, and encouraging
- Use simple language that beginners can understand
- Focus on educational content about investing, trading, and financial literacy

User question: $userMessage

Please provide a helpful, educational response about investing or financial literacy. Keep it under 200 words and make it encouraging for someone learning about finance.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ??
          "I'm sorry, I couldn't generate a response right now. Please try again!";
    } catch (e) {
      print('Error getting AI response: $e');
      return "I'm having trouble connecting right now. Please try again in a moment!";
    }
  }

  // Get a welcome message for new users
  static Future<String> getWelcomeMessage() async {
    return '''
Hello! I'm your AI financial mentor for the Finx app! 🤖💰

I'm here to help you learn about investing, trading, and financial literacy in a fun and safe way. Since this is a simulation, you can experiment and learn without any real financial risk!

Here are some things you can ask me about:
• "What is a stock?"
• "How do I diversify my portfolio?"
• "What's the difference between a bull and bear market?"
• "How do I read stock charts?"
• "What are ETFs and mutual funds?"
• "How do I manage risk when trading?"

Feel free to ask me anything about investing or finance - I'm here to help you become a smarter investor! 🚀
''';
  }

  // Get quick tips about investing
  static Future<String> getRandomTip() async {
    final tips = [
      "💡 **Diversification is key!** Don't put all your virtual money into one stock. Spread it across different sectors to reduce risk.",
      "📈 **Start small and learn!** In real investing, start with money you can afford to lose. This simulation is perfect for practice!",
      "🎯 **Set clear goals!** Are you investing for short-term gains or long-term growth? Your strategy should match your goals.",
      "📊 **Do your research!** Before buying any stock, research the company, its financials, and market trends.",
      "⏰ **Time in the market beats timing the market!** Long-term investing often outperforms trying to time the market perfectly.",
      "💰 **Compound interest is powerful!** Even small, consistent investments can grow significantly over time.",
      "🛡️ **Risk management matters!** Never invest more than you can afford to lose, and always have an emergency fund.",
      "📚 **Keep learning!** The financial world is always changing. Stay curious and keep educating yourself!",
    ];

    return tips[DateTime.now().millisecondsSinceEpoch % tips.length];
  }
}
