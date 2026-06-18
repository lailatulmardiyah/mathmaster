import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_question.dart';
import '../widgets/custom_button.dart';
import 'package:fl_chart/fl_chart.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _quizStarted = false;
  bool _quizFinished = false;

  String playerName = '';
  String playerPin = '';

  List<Map<String, dynamic>> _quizHistory = [];
bool _isLoadingHistory = false;

  // ================= START QUIZ =================
  void _startQuiz() {
    final all = QuizQuestion.getAllQuestions();
    _questions = List.from(all)..shuffle();
    _questions = _questions.take(10).toList();

    setState(() {
      _quizStarted = true;
      _quizFinished = false;
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
    });
  }

  // ================= ANSWER =================
  void _selectAnswer(int index) {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = index;

      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  // ================= NEXT =================
  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _quizFinished = true;
      });

      _saveToSupabase();
    }
  }

  // ================= SAVE TO SUPABASE =================
  Future<void> _saveToSupabase() async {
    try {
      final percent = (_score / _questions.length) * 100;

      await supabase.from('quiz_result').insert({
        'name': playerName,
        'pin': playerPin,
        'score': _score,
        'total': _questions.length,
      });

      debugPrint("✔ Quiz tersimpan ke Supabase");
      _fetchQuizHistory();
    } catch (e) {
      debugPrint("❌ Gagal simpan quiz: $e");
    }
  }

  Future<void> _fetchQuizHistory() async {
    if (playerName.isEmpty) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final response = await supabase
          .from('quiz_result')
          .select('score, created_at')
          .eq('name', playerName)
          .eq('pin', playerPin)
          .order('created_at', ascending: true);

      setState(() {
        _quizHistory = List<Map<String, dynamic>>.from(response);
        _isLoadingHistory = false;
      });
    } catch (e) {
      debugPrint("❌ Gagal mengambil riwayat kuis: $e");
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  // ================= RESET =================
  void _reset() {
    setState(() {
      _quizStarted = false;
      _quizFinished = false;
      _questions = [];
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      playerName = '';
      playerPin = '';
      _nameController.clear();
      _pinController.clear();
    });
  }

  Widget _buildProgressChart() {
    if (_isLoadingHistory) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < _quizHistory.length; i++) {
      double score = double.tryParse(_quizHistory[i]['score'].toString()) ?? 0.0;
      spots.add(FlSpot(i.toDouble() + 1, score));
    }

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Grafik Perkembangan Skor",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('K${value.toInt()}', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: _quizHistory.length.toDouble() > 5 ? _quizHistory.length.toDouble() : 5,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 4,
                    color: Colors.blue,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= INPUT NAMA =================
            if (!_quizStarted)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Pemain",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            TextField(
                controller: _pinController,
                keyboardType: TextInputType.number, // Hanya memunculkan keyboard angka
                maxLength: 4, // Membatasi PIN maksimal 4 digit
                obscureText: true, // Menyembunyikan angka (menjadi titik-titik) demi privasi
                decoration: InputDecoration(
                  labelText: "PIN (4 Digit Angka)",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
            ),

            // ================= STATUS =================
            if (playerName.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Player : $playerName",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ================= QUESTION BOX =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _quizFinished
                  ? Column(
                      children: [
                        const Icon(Icons.emoji_events,
                            size: 80, color: Colors.white),
                        const SizedBox(height: 10),
                        Text(
                          "Skor: $_score/${_questions.length}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                          !_quizStarted
                              ? "Masukkan nama lalu mulai"
                              : _questions[_currentIndex].question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // ================= OPTIONS =================
            if (_quizStarted && !_quizFinished)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions[_currentIndex].options.length,
                itemBuilder: (context, index) {
                  final q = _questions[_currentIndex];
                  final isCorrect = index == q.correctIndex;
                  final isSelected = _selectedAnswer == index;

                  Color bg = Colors.white;
                  if (_selectedAnswer != null) {
                    if (isCorrect) {
                      bg = Colors.green;
                    } else if (isSelected) {
                      bg = Colors.red;
                    }
                  }

                  return GestureDetector(
                    onTap: () => _selectAnswer(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        q.options[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // ================= BUTTON =================
            CustomButton(
              text: !_quizStarted
                  ? "Mulai Quiz"
                  : (_quizFinished ? "Ulangi" : "Selanjutnya"),
              onPressed: () {
                if (!_quizStarted) {
                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Isi nama dulu"),
                      ),
                    );
                    return;
                  }

                  if (_pinController.text.trim().length < 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("PIN harus 4 digit angka")),
                    );
                    return;
                  }

                  playerName = _nameController.text.trim();
                  playerPin = _pinController.text.trim();
                  
                  _startQuiz();

                  _fetchQuizHistory();

                } else if (_quizFinished) {
                  _reset();
                } else {
                  _next();
                }
              },
            ),
            _buildProgressChart(),
          ],
        ),
      ),
    );
  }
}