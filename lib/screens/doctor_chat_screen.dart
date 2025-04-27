import 'package:flutter/material.dart';
import '../models/doctor.dart';
import 'book_appointment_screen.dart';
import 'widgets/chat_bubble.dart';

class DoctorChatScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorChatScreen({super.key, required this.doctor});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen>
    with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  List<String> userAnswers = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textAnswerController = TextEditingController();
  bool isTyping = false;

  final Map<String, List<String>> specializationQuestions = const {
    'Neurologist': [
      "Hello! 👋",
      "Do you experience frequent headaches or migraines? (Yes/No)",
      "Any memory or concentration issues?",
      "Have you noticed tremors or unusual movements? (Yes/No)",
      "Do you feel dizzy or lose balance often? (Yes/No)",
    ],
    'Nutritionist/Dietitian': [
      "Hi! Let's talk about your diet 🥗",
      "What are your current eating habits?",
      "Do you have food allergies or restrictions? (Yes/No)",
      "What’s your water intake per day?",
      "Are you trying to gain or lose weight? (Gain/Lose/Maintain)",
    ],
    'General Physician': [
      "Hi there! 🩺",
      "Are you feeling unwell today? (Yes/No)",
      "What symptoms are you experiencing?",
      "Do you take any medication regularly? (Yes/No)",
      "Have you had any recent tests or diagnoses?",
    ],
    'Psychologist': [
      "Hello! 🧠",
      "Have you experienced stress, anxiety, or depression recently? (Yes/No)",
      "How is your sleep quality?",
      "Do you feel socially withdrawn or overwhelmed?",
      "Are you currently seeing a therapist or counselor? (Yes/No)",
    ],
    'Cardiologist (Heart Specialist)': [
      "Hi! ❤️ Let's check your heart health.",
      "Do you experience chest pain or shortness of breath? (Yes/No)",
      "Do you have high cholesterol or blood pressure?",
      "How often do you exercise in a week?",
      "Any heart problems in your family? (Yes/No)",
    ],
    'Orthopedic Surgeon': [
      "Welcome! 🦴",
      "Where do you feel pain or discomfort?",
      "Have you had previous bone or joint injuries?",
      "Do you have difficulty walking or standing? (Yes/No)",
      "Are you under physiotherapy or treatment currently? (Yes/No)",
    ],
    'Physiotherapist': [
      "Hello! 🏃",
      "Are you recovering from surgery or injury? (Yes/No)",
      "What movement or physical activity causes you pain?",
      "Are you following any exercise/stretching routine?",
      "Would you like a tailored home rehab plan? (Yes/No)",
    ],
    'Dermatologist (Skin Specialist)': [
      "Hi! Let's talk about your skin 🧴",
      "Do you have acne, eczema, or psoriasis? (Yes/No)",
      "Have you noticed sudden changes in skin or moles?",
      "Do you use sunscreen regularly? (Yes/No)",
      "Are you currently on skincare medication?",
    ],
    'Pediatrician (Child Specialist)': [
      "Hello! 👶",
      "Is the child facing fever or cough? (Yes/No)",
      "Any recent behavioral changes?",
      "Is the child vaccinated as per schedule? (Yes/No)",
      "Do they have allergies or medical conditions?",
    ],
    'Gynecologist (Women\'s Health)': [
      "Hi! 👩‍⚕️",
      "Do you face menstrual irregularities or pain? (Yes/No)",
      "Are you currently pregnant or breastfeeding? (Yes/No)",
      "Do you have concerns regarding fertility or hormones?",
      "Do you go for regular pelvic checkups? (Yes/No)",
    ],
    'Gastroenterologist (Stomach Specialist)': [
      "Hello! 🍽️",
      "Do you often feel bloated or have indigestion? (Yes/No)",
      "Do you have constipation or diarrhea frequently?",
      "Any past diagnosis of ulcers or IBS? (Yes/No)",
      "Are certain foods triggering discomfort?",
    ],
  };

  List<String> getQuestionsForSpecialization(String specialization) {
    return specializationQuestions[specialization] ??
        [
          "Hi there! 👋",
          "Can you tell me a bit about your health concern?",
          "Have you seen a doctor about this before? (Yes/No)",
          "Are you currently taking any medications? (Yes/No)",
          "Do you have any other symptoms you'd like to mention?",
        ];
  }

  void _selectAnswer(String answer) {
    setState(() {
      userAnswers.add(answer);
      isTyping = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        isTyping = false;
        currentQuestionIndex++;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void _handleTextInput(String text) {
    if (text.trim().isEmpty) return;
    _selectAnswer(text.trim());
    _textAnswerController.clear();
  }

  bool _isYesNoQuestion(String question) {
    return question.contains('(Yes/No)');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = getQuestionsForSpecialization(
      widget.doctor.specialization,
    );
    final bool allAnswered = currentQuestionIndex >= questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dr. ${widget.doctor.name}"),
        backgroundColor: Colors.green.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    allAnswered
                        ? userAnswers.length * 2
                        : userAnswers.length * 2 + 1,
                itemBuilder: (context, index) {
                  if (index.isEven) {
                    final questionIndex = index ~/ 2;
                    return ChatBubble(
                      isUser: false,
                      message: questions[questionIndex],
                    );
                  } else {
                    final answerIndex = (index - 1) ~/ 2;
                    return ChatBubble(
                      isUser: true,
                      message: userAnswers[answerIndex],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            if (allAnswered)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BookAppointmentScreen(doctor: widget.doctor),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text("Book Appointment"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  minimumSize: const Size.fromHeight(50),
                ),
              )
            else if (isTyping)
              const CircularProgressIndicator()
            else
              _buildInputSection(questions[currentQuestionIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(String currentQuestion) {
    if (_isYesNoQuestion(currentQuestion)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _selectAnswer("Yes"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Yes"),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _selectAnswer("No"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("No"),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textAnswerController,
              decoration: const InputDecoration(
                hintText: 'Type your answer...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _handleTextInput,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.green,
            onPressed: () => _handleTextInput(_textAnswerController.text),
          ),
        ],
      );
    }
  }
}
