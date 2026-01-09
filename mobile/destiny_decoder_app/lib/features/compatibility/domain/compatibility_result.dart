class CompatibilityResult {
  final PersonReading personA;
  final PersonReading personB;
  final CompatibilityScores compatibility;

  CompatibilityResult({
    required this.personA,
    required this.personB,
    required this.compatibility,
  });

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) {
    return CompatibilityResult(
      personA: PersonReading.fromJson(json['person_a'] as Map<String, dynamic>? ?? {}),
      personB: PersonReading.fromJson(json['person_b'] as Map<String, dynamic>? ?? {}),
      compatibility: CompatibilityScores.fromJson(json['compatibility'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person_a': personA.toJson(),
      'person_b': personB.toJson(),
      'compatibility': compatibility.toJson(),
    };
  }
}

class PersonReading {
  final PersonInput input;
  final Map<String, dynamic> core;
  final PersonInterpretations interpretations;

  PersonReading({
    required this.input,
    required this.core,
    required this.interpretations,
  });

  factory PersonReading.fromJson(Map<String, dynamic> json) {
    return PersonReading(
      input: PersonInput.fromJson(json['input'] as Map<String, dynamic>? ?? {}),
      core: json['core'] as Map<String, dynamic>? ?? {},
      interpretations: PersonInterpretations.fromJson(json['interpretations'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input.toJson(),
      'core': core,
      'interpretations': interpretations.toJson(),
    };
  }
}

class PersonInput {
  final String fullName;
  final String dateOfBirth;

  PersonInput({
    required this.fullName,
    required this.dateOfBirth,
  });

  factory PersonInput.fromJson(Map<String, dynamic> json) {
    return PersonInput(
      fullName: json['full_name'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
    };
  }
}

class PersonInterpretations {
  final NumberInterpretation lifeSeal;
  final SoulInterpretation soulNumber;
  final SoulInterpretation personalityNumber;
  final NumberInterpretation personalYear;

  PersonInterpretations({
    required this.lifeSeal,
    required this.soulNumber,
    required this.personalityNumber,
    required this.personalYear,
  });

  factory PersonInterpretations.fromJson(Map<String, dynamic> json) {
    return PersonInterpretations(
      lifeSeal: NumberInterpretation.fromJson(json['life_seal'] as Map<String, dynamic>? ?? {}),
      soulNumber: SoulInterpretation.fromJson(json['soul_number'] as Map<String, dynamic>? ?? {}),
      personalityNumber: SoulInterpretation.fromJson(json['personality_number'] as Map<String, dynamic>? ?? {}),
      personalYear: NumberInterpretation.fromJson(json['personal_year'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'life_seal': lifeSeal.toJson(),
      'soul_number': soulNumber.toJson(),
      'personality_number': personalityNumber.toJson(),
      'personal_year': personalYear.toJson(),
    };
  }
}

class NumberInterpretation {
  final int number;
  final String planet;
  final Map<String, dynamic> content;

  NumberInterpretation({
    required this.number,
    required this.planet,
    required this.content,
  });

  factory NumberInterpretation.fromJson(Map<String, dynamic> json) {
    return NumberInterpretation(
      number: json['number'] as int? ?? 0,
      planet: json['planet'] as String? ?? '',
      content: json['content'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'planet': planet,
      'content': content,
    };
  }
}

class SoulInterpretation {
  final int number;
  final Map<String, dynamic> content;

  SoulInterpretation({
    required this.number,
    required this.content,
  });

  factory SoulInterpretation.fromJson(Map<String, dynamic> json) {
    return SoulInterpretation(
      number: json['number'] as int? ?? 0,
      content: json['content'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'content': content,
    };
  }
}

class CompatibilityScores {
  final String overall;
  final String lifeSeal;
  final String soulNumber;
  final String personalityNumber;
  final int score;
  final int maxScore;

  CompatibilityScores({
    required this.overall,
    required this.lifeSeal,
    required this.soulNumber,
    required this.personalityNumber,
    required this.score,
    required this.maxScore,
  });

  factory CompatibilityScores.fromJson(Map<String, dynamic> json) {
    return CompatibilityScores(
      overall: json['overall'] as String? ?? '',
      lifeSeal: json['life_seal'] as String? ?? '',
      soulNumber: json['soul_number'] as String? ?? '',
      personalityNumber: json['personality_number'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      maxScore: json['max_score'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'life_seal': lifeSeal,
      'soul_number': soulNumber,
      'personality_number': personalityNumber,
      'score': score,
      'max_score': maxScore,
    };
  }

  double get percentage => (score / maxScore) * 100;
}
