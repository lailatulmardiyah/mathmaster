import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../widgets/custom_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _totalQuestions = 0;
  int? _selectedAnswer;
  bool _showResult = false;

  void _startQuiz() {
    final allQuestions = QuizQuestion.getAllQuestions();
    _questions = List.from(allQuestions)..shuffle();
    _questions = _questions.take(10).toList();
    _currentIndex = 0;
    _score = 0;
    _totalQuestions = _questions.length;
    _selectedAnswer = null;
    _showResult = false;

    setState(() {});
  }

  void _selectAnswer(int index) {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = index;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _showResult = true;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Score Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Skor: $_score/$_totalQuestions',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4facfe),
                  ),
                ),
                if (_totalQuestions > 0)
                  Text(
                    '${((_score / _totalQuestions) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4facfe),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Question
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF093FB),
                    Color(0xFFF5576C),
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: _showResult
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events, size: 80, color: Colors.white),
                        const SizedBox(height: 20),
                        Text(
                          'Kuis Selesai!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Skor: $_score/$_totalQuestions',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '${((_score / _totalQuestions) * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pertanyaan ${_currentIndex + 1}/$_totalQuestions',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _questions.isEmpty
                              ? 'Klik Mulai untuk memulai kuis!'
                              : _questions[_currentIndex].question,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          
          
          // Options
          if (!_showResult && _questions.isNotEmpty)
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                  itemCount: _questions[_currentIndex].options.length,
                  itemBuilder: (context, index) {
                    final isCorrect = index == _questions[_currentIndex].correctIndex;
                    final isSelected = _selectedAnswer == index;
                    final isAnswered = _selectedAnswer != null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: isAnswered ? null : () => _selectAnswer(index),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isAnswered
                                ? (isCorrect
                                    ? const Color(0xFF4facfe)
                                    : (isSelected ? Colors.red : Colors.white))
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAnswered
                                  ? (isCorrect ? const Color(0xFF4facfe) : Colors.red)
                                  : Colors.grey[300]!,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isAnswered
                                      ? (isCorrect
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2))
                                      : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isAnswered ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _questions[_currentIndex].options[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isAnswered ? Colors.white : Colors.black87,
                                  ),
                                ),
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
          
          // Controls
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: _showResult ? 'Kuis Baru' : 'Mulai Kuis',
                    onPressed: _questions.isEmpty ? _startQuiz : _resetQuiz,
                  ),
                ),
                if (_selectedAnswer != null && !_showResult)
                  Expanded(
                    child: CustomButton(
                      text: _currentIndex < _questions.length - 1 ? 'Selanjutnya' : 'Selesai',
                      onPressed: _nextQuestion,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      )
    );
  }
}