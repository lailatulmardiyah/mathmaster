import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _lengthResult = '';
  String _tempResult = '';
  String _weightResult = '';

  void _convertLength() {
    final value = double.tryParse(_lengthController.text);
    if (value == null) {
      Fluttertoast.showToast(msg: 'Masukkan angka yang valid!');
      return;
    }
    setState(() {
      _lengthResult = '${value.toStringAsFixed(2)} m = ${(value * 100).toStringAsFixed(0)} cm';
    });
  }

  void _convertTemp() {
    final value = double.tryParse(_tempController.text);
    if (value == null) {
      Fluttertoast.showToast(msg: 'Masukkan angka yang valid!');
      return;
    }
    final result = (value * 9 / 5) + 32;
    setState(() {
      _tempResult = '${value.toStringAsFixed(1)}°C = ${result.toStringAsFixed(1)}°F';
    });
  }

  void _convertWeight() {
    final value = double.tryParse(_weightController.text);
    if (value == null) {
      Fluttertoast.showToast(msg: 'Masukkan angka yang valid!');
      return;
    }
    final result = value * 2.20462;
    setState(() {
      _weightResult = '${value.toStringAsFixed(2)} kg = ${result.toStringAsFixed(2)} lbs';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildConverterCard(
            title: 'Panjang (m → cm)',
            controller: _lengthController,
            onConvert: _convertLength,
            result: _lengthResult,
          ),
          const SizedBox(height: 20),
          _buildConverterCard(
            title: 'Suhu (°C → °F)',
            controller: _tempController,
            onConvert: _convertTemp,
            result: _tempResult,
          ),
          const SizedBox(height: 20),
          _buildConverterCard(
            title: 'Berat (kg → lbs)',
            controller: _weightController,
            onConvert: _convertWeight,
            result: _weightResult,
          ),
        ],
      ),
    );
  }

  Widget _buildConverterCard({
    required String title,
    required TextEditingController controller,
    required VoidCallback onConvert,
    required String result,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Masukkan nilai',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConvert,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Konversi', style: TextStyle(fontSize: 16)),
            ),
          ),
          if (result.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4facfe).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4facfe)),
              ),
              child: Text(
                result,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4facfe),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}