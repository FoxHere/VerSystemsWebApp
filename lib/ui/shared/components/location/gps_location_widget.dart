import 'package:flutter/material.dart' as m;
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/gps_location_response_model.dart';
import 'package:versystems_app/ui/shared/components/location/gps_location_view_model.dart';

class GpsLocationWidget extends StatefulWidget {
  final GpsLocationResponseModel? initialLocation;
  final ValueChanged<GpsLocationResponseModel> onLocationCaptured;
  final bool isReadMode;

  const GpsLocationWidget({
    super.key,
    this.initialLocation,
    required this.onLocationCaptured,
    this.isReadMode = false,
  });

  @override
  State<GpsLocationWidget> createState() => _GpsLocationWidgetState();
}

class _GpsLocationWidgetState extends State<GpsLocationWidget>
    with FormValueSupplier<GpsLocationResponseModel, GpsLocationWidget> {
  late final GpsLocationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GpsLocationViewModel();
    _viewModel.initWithValue(widget.initialLocation);
    if (widget.initialLocation != null) {
      formValue = widget.initialLocation;
    }
  }

  @override
  void didReplaceFormValue(GpsLocationResponseModel value) {
    if (mounted) {
      _viewModel.initWithValue(value);
    }
  }

  void _captureLocation() {
    _viewModel.fetchLocation(
      onLocationCaptured: (location) {
        formValue = location;
        widget.onLocationCaptured(location);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = _viewModel.state.value;
      final location = _viewModel.locationData.value;
      final errorMsg = _viewModel.errorMessage.value;

      switch (state) {
        case GpsLocationState.initial:
          return _buildInitialState(context);

        case GpsLocationState.loading:
          return _buildLoadingState(context);

        case GpsLocationState.success:
          if (location != null) {
            return _buildSuccessState(context, location);
          }
          return _buildInitialState(context);

        case GpsLocationState.permissionDenied:
          return _buildErrorCard(
            context,
            title: 'Permissão de Localização Negada',
            message: errorMsg.isNotEmpty
                ? errorMsg
                : 'A permissão de localização foi negada no navegador. Permita o acesso à localização para continuar.',
            icon: Symbols.location_disabled,
          );

        case GpsLocationState.locationUnavailable:
          return _buildErrorCard(
            context,
            title: 'Localização Indisponível',
            message: errorMsg.isNotEmpty
                ? errorMsg
                : 'O serviço de localização (GPS) está desativado no navegador/dispositivo.',
            icon: Symbols.location_off,
          );

        case GpsLocationState.error:
          return _buildErrorCard(
            context,
            title: 'Erro ao Capturar Localização',
            message: errorMsg.isNotEmpty
                ? errorMsg
                : 'Não foi possível obter a localização atual. Verifique sua conexão e tente novamente.',
            icon: Symbols.error_outline,
          );
      }
    });
  }

  Widget _buildInitialState(BuildContext context) {
    if (widget.isReadMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: const Text('Sem resposta').large().muted(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryButton(
          onPressed: _captureLocation,
          leading: const Icon(Symbols.my_location, size: 18),
          child: const Text('Obter localização atual'),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(20),
      child: Row(
        spacing: 16,
        children: [
          const CircularProgressIndicator(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Obtendo localização GPS...').bold(),
                const Text('Aguardando resposta do navegador/GPS').xSmall().muted(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, GpsLocationResponseModel location) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final formattedDate = dateFormat.format(location.capturedAt);

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Header badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  const Icon(Symbols.check_circle, size: 20, color: m.Colors.green),
                  const Text('Localização capturada').bold(),
                ],
              ),
              OutlineBadge(
                child: Text('Lat: ${location.latitude.toStringAsFixed(5)}, Lng: ${location.longitude.toStringAsFixed(5)}'),
              ),
            ],
          ),

          // Map view
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.border),
            ),
            clipBehavior: Clip.hardEdge,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(location.latitude, location.longitude),
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.versystems.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(location.latitude, location.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        m.Icons.location_pin,
                        color: m.Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Precisão: aproximadamente ${location.accuracy.toStringAsFixed(1)} metros')
                        .small()
                        .bold(),
                    Text('Capturado em: $formattedDate').xSmall().muted(),
                  ],
                ),
              ),
              if (!widget.isReadMode)
                OutlineButton(
                  onPressed: _captureLocation,
                  leading: const Icon(Symbols.refresh, size: 16),
                  child: const Text('Atualizar localização'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context, {
    required String title,
    required String message,
    required m.IconData icon,
  }) {
    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.destructive),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.destructive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(message).small().muted(),
          if (!widget.isReadMode)
            OutlineButton(
              onPressed: _captureLocation,
              leading: const Icon(Symbols.refresh, size: 16),
              child: const Text('Tentar novamente'),
            ),
        ],
      ),
    );
  }
}
