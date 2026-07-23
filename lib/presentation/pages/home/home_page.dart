import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/recycle_viewmodel.dart';
import '../../widgets/camera_preview_widget.dart';
import '../../widgets/analysis_result_widget.dart';
import '../../widgets/error_display_widget.dart';

/// Pantalla principal de la aplicación rECOCam.
/// Muestra la cámara o los resultados del análisis.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final RecycleViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = context.read<RecycleViewModel>();
    _viewModel.addListener(_onViewModelChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize();
    });
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.recycling,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text(
            'rECOCam',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_viewModel.isLoading && _viewModel.capturedImage == null) {
      return _buildLoadingState(context);
    }

    if (_viewModel.errorMessage.isNotEmpty) {
      return ErrorDisplayWidget(
        message: _viewModel.errorMessage,
        onRetry: () => _viewModel.resetAnalysis(),
      );
    }

    if (_viewModel.showCamera) {
      return CameraPreviewWidget(
        onCapture: () => _viewModel.capturePhoto(),
        onClose: () => _viewModel.hideCameraView(),
      );
    }

    if (_viewModel.result != null && _viewModel.capturedImage != null) {
      return AnalysisResultWidget(
        result: _viewModel.result!,
        imageFile: _viewModel.capturedImage!,
      );
    }

    return _buildInitialState(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Preparando modelo de IA...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Esto puede tardar unos segundos la primera vez.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_rounded,
              size: 100,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 32),
            Text(
              'Analiza tus residuos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Toma una foto de un objeto para saber '
              'si es reciclable, reutilizable y en qué '
              'contenedor debes depositarlo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _viewModel.isInitialized
                  ? () => _viewModel.initializeCamera()
                  : null,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar fotografía'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _viewModel.isInitialized
                  ? () => _viewModel.pickFromGallery()
                  : null,
              icon: const Icon(Icons.photo_library),
              label: const Text('Seleccionar de galería'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context) {
    if (_viewModel.result == null) return null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () => _viewModel.resetAnalysis(),
          icon: const Icon(Icons.refresh),
          label: const Text('Analizar nuevamente'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
