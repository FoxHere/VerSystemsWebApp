import 'package:flutter/material.dart';

class QuestionCount extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestionIndex;
  const QuestionCount({super.key, required this.currentQuestionIndex, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Pergunta $currentQuestionIndex de $totalQuestions',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
