class DecodeResult {
  final DecodeInput input;
  final Map<String, dynamic> core;
  final LifeSealInterpretation lifeSeal;
  final SoulNumberInterpretation soulNumber;
  final SoulNumberInterpretation personalityNumber;
  final LifeSealInterpretation personalYear;
  final List<LifeSealInterpretation> pinnacles;

  DecodeResult({
    required this.input,
    required this.core,
    required this.lifeSeal,
    required this.soulNumber,
    required this.personalityNumber,
    required this.personalYear,
    required this.pinnacles,
  });

  Map<String, dynamic> toJson() {
    return {
      'input': input.toJson(),
      'core': core,
      'interpretations': {
        'life_seal': lifeSeal.toJson(),
        'soul_number': soulNumber.toJson(),
        'personality_number': personalityNumber.toJson(),
        'personal_year': personalYear.toJson(),
        'pinnacles': pinnacles.map((p) => p.toJson()).toList(),
      },
    };
  }

  factory DecodeResult.fromJson(Map<String, dynamic> json) {
    return DecodeResult(
      input: DecodeInput.fromJson(json['input'] as Map<String, dynamic>? ?? {}),
      core: json['core'] as Map<String, dynamic>? ?? {},
      lifeSeal: LifeSealInterpretation.fromJson(
        (json['interpretations']?['life_seal'] as Map<String, dynamic>?) ?? {},
      ),
      soulNumber: SoulNumberInterpretation.fromJson(
        (json['interpretations']?['soul_number'] as Map<String, dynamic>?) ?? {},
      ),
      personalityNumber: SoulNumberInterpretation.fromJson(
        (json['interpretations']?['personality_number'] as Map<String, dynamic>?) ?? {},
      ),
      personalYear: LifeSealInterpretation.fromJson(
        (json['interpretations']?['personal_year'] as Map<String, dynamic>?) ?? {},
      ),
      pinnacles: (json['interpretations']?['pinnacles'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(LifeSealInterpretation.fromJson)
              .toList() ??
          [],
    );
  }
}

class DecodeInput {
  final String fullName;
  final String dateOfBirth;

  DecodeInput({
    required this.fullName,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
    };
  }

  factory DecodeInput.fromJson(Map<String, dynamic> json) {
    return DecodeInput(
      fullName: json['full_name'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
    );
  }
}

class LifeSealInterpretation {
  final int number;
  final String planet;
  final Map<String, dynamic> content;

  LifeSealInterpretation({
    required this.number,
    required this.planet,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'planet': planet,
      'content': content,
    };
  }

  factory LifeSealInterpretation.fromJson(Map<String, dynamic> json) {
    return LifeSealInterpretation(
      number: json['number'] as int? ?? 0,
      planet: json['planet'] as String? ?? '',
      content: json['content'] as Map<String, dynamic>? ?? {},
    );
  }
}

class SoulNumberInterpretation {
  final int number;
  final Map<String, dynamic> content;

  SoulNumberInterpretation({
    required this.number,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'content': content,
    };
  }

  factory SoulNumberInterpretation.fromJson(Map<String, dynamic> json) {
    return SoulNumberInterpretation(
      number: json['number'] as int? ?? 0,
      content: json['content'] as Map<String, dynamic>? ?? {},
    );
  }
}
