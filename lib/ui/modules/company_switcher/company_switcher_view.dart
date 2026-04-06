import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';

class CompanySwitcherView extends StatefulWidget {
  const CompanySwitcherView({super.key});

  @override
  State<CompanySwitcherView> createState() => _CompanySwitcherViewState();
}

class _CompanySwitcherViewState extends State<CompanySwitcherView> {
  final _companyRepository = Get.find<CompanyRepositoryImpl>();
  List<CompanyModel> _companies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    final result = await _companyRepository.findAllCompanies({});
    result.fold(
      (l) {
        if (mounted) {
          setState(() {
            _error = l.message;
            _isLoading = false;
          });
        }
      },
      (r) {
        if (mounted) {
          setState(() {
            _companies = r;
            _isLoading = false;
          });
        }
      },
    );
  }

  void _switchCompany(CompanyModel company) {
    AppSessionController.instance.setCompanyId(company.id);
    // Force direct reload by routing to dashboard
    context.go(RoutesHelper.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final currentCompanyId = AppSessionController.instance.companyId;

    return Scaffold(
      headers: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              OutlineButton(
                density: ButtonDensity.icon,
                onPressed: () {
                  context.go(RoutesHelper.dashboard);
                },
                child: const Icon(LucideIcons.arrowLeft),
              ),
              const SizedBox(width: 16),
              const Text('Configurações de Workspace').h4(),
            ],
          ),
        ),
        const Divider(),
      ],
      child: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selecione uma Empresa', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Você está prestes a mudar o contexto da sua aplicação. Os dados exibidos serão isolados por tenant.').muted(),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Center(child: Text('Erro: $_error').muted())
              else if (_companies.isEmpty)
                const Center(child: Text('Nenhuma empresa encontrada.'))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _companies.length,
                    itemBuilder: (context, index) {
                      final company = _companies[index];
                      final isCurrent = company.id == currentCompanyId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.building2, size: 32).withPadding(right: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(company.name).medium(),
                                    Text(company.cnpj).muted().withPadding(top: 4),
                                  ],
                                ),
                              ),
                              if (isCurrent) const OutlineBadge(child: Text('Atual')),
                              if (!isCurrent)
                                PrimaryButton(
                                  onPressed: () => _switchCompany(company),
                                  child: const Text('Selecionar'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
