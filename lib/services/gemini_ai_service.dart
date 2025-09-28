import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiAIService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static GenerativeModel? _model;

  // Initialize the Gemini model
  static void initialize() {
    print('🔧 Initializing Gemini AI Service...');
    print('🔑 API Key loaded: ${_apiKey.isNotEmpty ? "✅ Yes" : "❌ No"}');
    print('🔑 API Key length: ${_apiKey.length}');
    print('🔑 API Key preview: ${_apiKey.substring(0, 10)}...');

    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
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
    print('🤖 Getting financial advice...');
    print('📝 User message: $userMessage');

    if (_model == null) {
      print('🔄 Model not initialized, initializing now...');
      initialize();
    }

    try {
      print('🚀 Sending request to Gemini API...');

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
      print('📤 Sending prompt to Gemini...');

      final response = await _model!.generateContent(content);
      print(
        '📥 Received response from Gemini: ${response.text?.substring(0, 50)}...',
      );

      return response.text ??
          "I'm sorry, I couldn't generate a response right now. Please try again!";
    } catch (e) {
      print('❌ Error getting financial advice: $e');
      print('❌ Error type: ${e.runtimeType}');

      // Fallback to contextual responses if API fails
      if (userMessage.toLowerCase().contains('portfolio')) {
        return "Your portfolio looks great! You have a good mix of stocks. Consider diversifying across different sectors for better risk management. What specific aspect of your portfolio would you like to discuss?";
      } else if (userMessage.toLowerCase().contains('buy') ||
          userMessage.toLowerCase().contains('sell')) {
        return "Great question about trading! Remember to always do your research before making investment decisions. Consider factors like company fundamentals, market trends, and your risk tolerance. What stock are you thinking about?";
      } else if (userMessage.toLowerCase().contains('risk')) {
        return "Risk management is crucial in investing! Consider diversifying your portfolio, setting stop-losses, and never investing more than you can afford to lose. Would you like me to explain any specific risk management strategies?";
      } else {
        return "Hello! I'm your AI financial mentor. I'm here to help you with your portfolio and investment questions. What would you like to know about investing, trading, or financial planning?";
      }
    }
  }

  // Get AI response with portfolio context
  static Future<String> getPortfolioAdvice(
    String userMessage,
    Map<String, dynamic> portfolioData,
  ) async {
    print('🤖 Getting portfolio advice...');
    print('📝 User message: $userMessage');
    print('💼 Portfolio data: $portfolioData');

    if (_model == null) {
      print('🔄 Model not initialized, initializing now...');
      initialize();
    }

    try {
      print('🚀 Sending request to Gemini API...');

      // Create a portfolio summary for context
      final portfolioSummary =
          '''
Portfolio Summary:
- Virtual Cash: \$${portfolioData['virtualCash']?.toStringAsFixed(2) ?? '0.00'}
- Total Value: \$${portfolioData['totalValue']?.toStringAsFixed(2) ?? '0.00'}
- Holdings: ${portfolioData['holdings']?.toString() ?? 'None'}
- Transaction History: ${portfolioData['transactionHistory']?.length ?? 0} transactions
''';

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

$portfolioSummary

User question: $userMessage

Please provide a helpful, educational response about their portfolio or investing. Keep it under 200 words and make it encouraging for someone learning about finance.
''';

      final content = [Content.text(prompt)];
      print('📤 Sending prompt to Gemini...');

      final response = await _model!.generateContent(content);
      print(
        '📥 Received response from Gemini: ${response.text?.substring(0, 50)}...',
      );

      return response.text ??
          "I'm sorry, I couldn't generate a response right now. Please try again!";
    } catch (e) {
      print('❌ Error getting portfolio advice: $e');
      print('❌ Error type: ${e.runtimeType}');

      // Fallback to contextual responses if API fails
      if (userMessage.toLowerCase().contains('portfolio')) {
        return "Your portfolio looks great! You have a good mix of stocks. Consider diversifying across different sectors for better risk management. What specific aspect of your portfolio would you like to discuss?";
      } else if (userMessage.toLowerCase().contains('buy') ||
          userMessage.toLowerCase().contains('sell')) {
        return "Great question about trading! Remember to always do your research before making investment decisions. Consider factors like company fundamentals, market trends, and your risk tolerance. What stock are you thinking about?";
      } else if (userMessage.toLowerCase().contains('risk')) {
        return "Risk management is crucial in investing! Consider diversifying your portfolio, setting stop-losses, and never investing more than you can afford to lose. Would you like me to explain any specific risk management strategies?";
      } else {
        return "Hello! I'm your AI financial mentor. I'm here to help you with your portfolio and investment questions. What would you like to know about investing, trading, or financial planning?";
      }
    }
  }

  // Get a welcome message for new users
  static Future<String> getWelcomeMessage() async {
    return '''
Hello! I'm your AI financial mentor for the Finx app! 🤖💰

I'm here to help you learn about investing, trading, and financial literacy in a fun and safe way. Since this is a simulation, you can experiment and learn without any real financial risk!

🎯 **I can see your portfolio!** I have access to your current holdings, cash, and performance, so I can give you personalized advice based on your specific situation.

Here are some things you can ask me about:
• "How is my portfolio doing?"
• "What should I invest in next?"
• "Is my portfolio diversified enough?"
• "What is a stock?"
• "How do I diversify my portfolio?"
• "What's the difference between a bull and bear market?"
• "How do I read stock charts?"
• "What are ETFs and mutual funds?"
• "How do I manage risk when trading?"

Feel free to ask me anything about investing, finance, or your specific portfolio - I'm here to help you become a smarter investor! 🚀
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
