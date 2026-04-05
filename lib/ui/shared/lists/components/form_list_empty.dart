import 'package:shadcn_flutter/shadcn_flutter.dart';

class FormListEmpty extends StatelessWidget {
  const FormListEmpty({super.key, required this.title, this.description, this.action});

  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final sizeOf = MediaQuery.of(context).size;
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          SizedBox(height: sizeOf.height * .15),
          Image.asset('assets/images/common/lists/list_empty_state.png', height: 200),
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.slate.shade400),
          ),
          SizedBox(
            width: 450,
            child: Text(
              description ?? 'Clique no botão "Novo Item" para criar o seu primeiro item',
              style: TextStyle(fontSize: 16, color: Colors.slate.shade300),
              textAlign: TextAlign.center,
            ),
          ),
          action ?? SizedBox.shrink(),
        ],
      ),
    );
  }
}
