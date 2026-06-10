class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  static List<QuizQuestion> getAllQuestions() {
    return [
      QuizQuestion(
        question: "Berapa hasil dari 15 + 27?",
        options: ["40", "42", "45", "48"],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: "Jika 4x = 20, berapa nilai x?",
        options: ["4", "5", "6", "8"],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: "Berapa 25% dari 80?",
        options: ["15", "18", "20", "25"],
        correctIndex: 2,
      ),
      QuizQuestion(
        question: "Luas persegi dengan sisi 7 cm adalah?",
        options: ["42 cm²", "49 cm²", "56 cm²", "63 cm²"],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: "Hasil dari 3² + 4² = ?",
        options: ["20", "22", "25", "29"],
        correctIndex: 2,
      ),
      QuizQuestion(
        question: "Berapa 2/3 dari 12?",
        options: ["6", "8", "9", "10"],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: "Jika a = 5 dan b = 3, berapa a × b - 2?",
        options: ["11", "13", "15", "17"],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: "Keliling persegi panjang 5 cm × 8 cm adalah?",
        options: ["18 cm", "26 cm", "36 cm", "40 cm"],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: "Berapa 1/4 dari 36?",
        options: ["6", "8", "9", "12"],
        correctIndex: 2,
      ),
      QuizQuestion(
        question: "Jika 5! (faktorial 5) = ?",
        options: ["60", "100", "150", "120"],
        correctIndex: 3,
      ),
    ];
  }
}