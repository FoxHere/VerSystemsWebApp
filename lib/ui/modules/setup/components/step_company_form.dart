import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/ui/modules/company_manager/company_form/components/company_form.dart';

/// Wrapper do Step 1 do wizard: dados da empresa.
/// Expõe [companyModel] e [validateForm] via GlobalKey<StepCompanyFormState>.
class StepCompanyForm extends StatefulWidget {
  final CompanyModel model;
  const StepCompanyForm({super.key, required this.model});

  @override
  State<StepCompanyForm> createState() => StepCompanyFormState();
}

class StepCompanyFormState extends State<StepCompanyForm> {
  final _formKey = GlobalKey<CompanyFormState>();

  CompanyModel get companyModel => _formKey.currentState?.companyModel ?? widget.model;

  bool validateForm() => _formKey.currentState?.validateForm() ?? false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: CompanyForm(key: _formKey, model: widget.model, hideAssignments: true),
        ),
      ),
    );
  }
}
