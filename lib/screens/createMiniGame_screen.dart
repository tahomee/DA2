import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateMinigameScreen extends StatefulWidget {
  @override
  _CreateMinigameScreenState createState() => _CreateMinigameScreenState();
}

class _CreateMinigameScreenState extends State<CreateMinigameScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _gameNameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '10');
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<Map<String, dynamic>> _questions = [];
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionsController = TextEditingController();
  final TextEditingController _correctAnswerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'TẠO MINIGAME',
          style: TextStyle(
            color: Color(0xFF3B6332),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF3B6332)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Tên minigame"),
              _buildInputField(_gameNameController, "Nhập tên minigame"),

              const SizedBox(height: 16),
              _buildLabel("Khuyến mãi (%)"),
              _buildInputField(
                _discountController,
                "Nhập phần trăm",
                inputType: TextInputType.number,
              ),

              const SizedBox(height: 16),
              _buildLabel("Thời gian"),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      controller: _startDateController,
                      label: 'Ngày bắt đầu',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      controller: _endDateController,
                      label: 'Ngày kết thúc',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                "Số lượng câu hỏi: ${_questions.length}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              _buildLabel("Câu hỏi"),
              _buildInputField(_questionController, "Nhập câu hỏi"),

              const SizedBox(height: 16),
              _buildLabel("Các lựa chọn"),
              _buildInputField(
                _optionsController,
                "Mỗi lựa chọn 1 dòng",
                maxLines: 4,
                inputType: TextInputType.multiline,
              ),

              const SizedBox(height: 16),
              _buildLabel("Lựa chọn đúng (số thứ tự)"),
              _buildInputField(
                _correctAnswerController,
                "Nhập số thứ tự",
                inputType: TextInputType.number,
              ),

              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _addQuestion,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF3B6332),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text('Thêm câu hỏi'),
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _submitMinigame,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF3B6332),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: const Text(
                    'Tạo minigame',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B6332),
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String hintText, {
        TextInputType inputType = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF3B6332)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF3B6332), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDateField({required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: label,
        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF3B6332)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF3B6332)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF3B6332), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          controller.text = "${date.day}/${date.month}/${date.year}";
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn ngày';
        }
        return null;
      },
    );
  }

  void _addQuestion() {
    if (_questionController.text.isEmpty ||
        _optionsController.text.isEmpty ||
        _correctAnswerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin câu hỏi')),
      );
      return;
    }

    final options = _optionsController.text.split('\n');
    final correctIndex = int.tryParse(_correctAnswerController.text) ?? 0;

    setState(() {
      _questions.add({
        'questionText': _questionController.text,
        'options': options,
        'correctOptionIndex': correctIndex,
      });

      _questionController.clear();
      _optionsController.clear();
      _correctAnswerController.clear();
    });
  }

  Future<void> _submitMinigame() async {
    if (_formKey.currentState!.validate() && _questions.isNotEmpty) {
      try {
        final startParts = _startDateController.text.split('/');
        final endParts = _endDateController.text.split('/');

        final startDate = DateTime(
          int.parse(startParts[2]),
          int.parse(startParts[1]),
          int.parse(startParts[0]),
        );

        final endDate = DateTime(
          int.parse(endParts[2]),
          int.parse(endParts[1]),
          int.parse(endParts[0]),
        );

        await _firestore.collection('minigames').add({
          'title': _gameNameController.text,
          'startDate': Timestamp.fromDate(startDate),
          'endDate': Timestamp.fromDate(endDate),
          'discountPercent': int.parse(_discountController.text),
          'questions': _questions,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo minigame thành công')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo minigame: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 câu hỏi')),
      );
    }
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _discountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _questionController.dispose();
    _optionsController.dispose();
    _correctAnswerController.dispose();
    super.dispose();
  }
}
