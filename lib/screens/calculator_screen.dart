import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';

  void _onPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'C':
          _expression = '';
          _result = '0';
          break;
        case '⌫':
          _expression = _expression.isEmpty ? '' : _expression.substring(0, _expression.length - 1);
          break;
        case '=':
          try {
            _result = _calculate(_expression);
          } catch (e) {
            _result = 'Error';
          }
          break;
        default:
          _expression += buttonText;
      }
    });
  }

  String _calculate(String expression) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression.replaceAll('×', '*'));
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    } catch (e) {
      return 'Error';
    }
  }

  Widget _buildButton({
    required String text,
    Color? backgroundColor,
    Color? textColor,
    bool isOperator = false,
    bool isLarge = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isLarge ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
    builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
            children: [
              // Display
              Flexible(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Column(
  children: [

    Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.history),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HistoryScreen(),
            ),
          );
        },
      ),
    ),

    Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _expression,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _result,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),
            ),
          ),
          const SizedBox(height: 8),
          // Buttons
          Flexible(
            flex: 5,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton(text: 'C', backgroundColor: Colors.red[400]),
                    _buildButton(text: '⌫', backgroundColor: Colors.orange[400]),
                    _buildButton(text: '/', backgroundColor: const Color(0xFFFF9500), isOperator: true),
                    _buildButton(text: '×', backgroundColor: const Color(0xFFFF9500), isOperator: true),
                  ],
                ),
                Row(
                  children: [
                    _buildButton(text: '7'),
                    _buildButton(text: '8'),
                    _buildButton(text: '9'),
                    _buildButton(text: '-', backgroundColor: const Color(0xFFFF9500), isOperator: true),
                  ],
                ),
                Row(
                  children: [
                    _buildButton(text: '4'),
                    _buildButton(text: '5'),
                    _buildButton(text: '6'),
                    _buildButton(text: '+', backgroundColor: const Color(0xFFFF9500), isOperator: true),
                  ],
                ),
                Row(
                  children: [
                    _buildButton(text: '1'),
                    _buildButton(text: '2'),
                    _buildButton(text: '3'),
                    _buildButton(text: '%', backgroundColor: const Color(0xFFFF9500), isOperator: true),
                  ],
                ),
                Row(
                  children: [
                    _buildButton(text: '0', isLarge: true),
                    _buildButton(text: '.'),
                    _buildButton(
                      text: '=',
                      backgroundColor: const Color(0xFF4facfe),
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
            )
          )
        )
        );
    }
    );
  }
}