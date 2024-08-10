import 'package:google_generative_ai/google_generative_ai.dart';

const String _apiKey = String.fromEnvironment('API_KEY_GEMINI');

class GenerativeModelInitializer {
  final String model;
  final String apiKey;
  final List<SafetySetting> safetySettings;
  final GenerationConfig generationConfigJson;
  final GenerationConfig generationConfigText;
  final Map<String, String> instructions;
  final double temperature;

  GenerativeModelInitializer({
    this.model = 'gemini-1.5-flash-latest',
    this.apiKey = _apiKey,
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfigJson,
    GenerationConfig? generationConfigText,
    Map<String, String>? instructions,
    this.temperature = 1.0,
  })  : safetySettings = safetySettings ?? _defaultSafetySettings,
        generationConfigJson =
            generationConfigJson ?? _defaultGenerationConfigJson(temperature),
        generationConfigText =
            generationConfigText ?? _defaultGenerationConfigText(temperature),
        instructions = instructions ?? _defaultInstructions;

  static final List<SafetySetting> _defaultSafetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
  ];

  static GenerationConfig _defaultGenerationConfigJson(double temperature) =>
      GenerationConfig(
        temperature: temperature,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: "application/json",
      );

  static GenerationConfig _defaultGenerationConfigText(double temperature) =>
      GenerationConfig(
        temperature: temperature,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: "text/plain",
      );

  static const Map<String, String> _defaultInstructions = {
    "General":
        "The general context needs to be about recycling in a correct way a waste. The user can provide a text or an image and you have to provide two answers: how to trash it in the best way possible and how the user can re-use the product to give it a second-life. Go straightforward to the point that the user want. Be eco-friendly and answer in a friendly-way",
    "Suggestions":
        "Generate a bulleted list of 4 items with suggestions of three-four words to start a conversation with a bot about how to recycle or curiosity about the recycling, waste, ecology. Be creative",
    "Tips":
        "Complete the phrase, without repeating my words, in a context where the user wants to know secrets and curiosity about recycling, like giving to it tips.",
  };

  GenerativeModel _createModel({
    required String systemInstruction,
    required bool json,
  }) {
    return GenerativeModel(
      model: model,
      apiKey: apiKey,
      systemInstruction: Content.system(systemInstruction),
      safetySettings: safetySettings,
      generationConfig: json ? generationConfigJson : generationConfigText,
    );
  }

  GenerativeModel createModelFromInstruction(
      String systemInstruction, bool json) {
    return _createModel(
      systemInstruction: systemInstruction,
      json: json,
    );
  }

  GenerativeModel createModelWithInstructionKey(String key,
      {bool json = false}) {
    final systemInstruction = instructions[key];
    if (systemInstruction != null) {
      return _createModel(
        systemInstruction: systemInstruction,
        json: json,
      );
    } else {
      throw Exception('Instruction key "$key" not valid.');
    }
  }

  GenerativeModel createModelNoSystemInstruction({bool json = false}) {
    return GenerativeModel(
      model: model,
      apiKey: apiKey,
      safetySettings: safetySettings,
      generationConfig: json ? generationConfigJson : generationConfigText,
    );
  }
}
