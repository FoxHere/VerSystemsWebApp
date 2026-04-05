// unused import removed
// empty
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/ui/modules/user_profile/user_profile_view_model.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';
import 'package:versystems_app/ui/shared/components/profile_image_picker/profile_image_picker.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> with MessageViewMixin, ResponsiveDeviceMixin, SingleTickerProviderStateMixin {
  final authController = Get.find<AuthController>();
  final userProfileViewModel = Get.find<UserProfileViewModel>();
  late AnimationController _controller;
  late Animation<double> _animation;
  final selectedProfileImage = Rx<ImageItemModel?>(null);

  @override
  void initState() {
    super.initState();
    messageListener(userProfileViewModel);
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Future<void> _pickAndUploadImage() async {
  //   final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     final bytes = await pickedFile.readAsBytes();
  //     final imageSize = bytes.length;
  //     final imageModel = ImageItemModel(bytes: bytes, name: pickedFile.name, sizeBytes: imageSize);
  //     await userProfileViewModel.updateProfileImage(imageModel);
  //   }
  // }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.muted.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title).muted().small(), const SizedBox(height: 4), Text(value.isNotEmpty ? value : '-').medium()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> items) {
    return Card(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Text(title).h4(),
            ],
          ),
          const SizedBox(height: 24),
          ...items,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();

    return Scaffold(
      child: Obx(() {
        final user = authController.localUserModel.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FadeTransition(
          opacity: _animation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    // Header / Cover / Avatar
                    SizedBox(
                      height: 260,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          // Cover background
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.border],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          //------------------------------- Avatar -------------------------------
                          Positioned(
                            bottom: 05,
                            child: ProfileImagePicker(
                              onImageSelected: (image) async {
                                if (image == null) return;
                                selectedProfileImage.value = image;
                                await userProfileViewModel.updateProfileImage(selectedProfileImage.value!);
                              },
                              initialImage: user.profileImage,
                              userName: user.name,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // User Name & Role
                    Text(user.name).h2(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        child: Text(user.role?.isNotEmpty == true ? user.role! : user.profile.name).medium(),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Info Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 700;
                        return Flex(
                          direction: isDesktop ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: isDesktop ? 1 : 0,
                              child: _buildInfoCard("Informações Pessoais", Symbols.person_outline, [
                                _buildInfoItem(Symbols.mail, "E-mail", user.email),
                                _buildInfoItem(Symbols.call, "Celular", user.cellphones.isNotEmpty ? user.cellphones.first : ''),
                                if (user.cpf != null && user.cpf!.isNotEmpty) _buildInfoItem(Symbols.badge, "CPF", user.cpf!),
                                if (user.birthDate != null && user.birthDate!.isNotEmpty)
                                  _buildInfoItem(Symbols.cake, "Data de Nascimento", user.birthDate!),
                              ]),
                            ),
                            if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
                            Expanded(
                              flex: isDesktop ? 1 : 0,
                              child: _buildInfoCard("Informações Profissionais", Symbols.work_outline, [
                                _buildInfoItem(Symbols.business, "Empresa", user.company),
                                _buildInfoItem(Symbols.groups, "Departamento", user.department.name),
                                _buildInfoItem(Symbols.vpn_key, "Perfil de Acesso", user.profile.name),
                                _buildInfoItem(Symbols.check_circle, "Status", user.isActive ? 'Ativo' : 'Inativo'),
                              ]),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
