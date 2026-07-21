import 'package:camera/camera.dart' show CameraPreview;
import 'package:flutter/material.dart';

import '../../../core/services/camera_service.dart';

/// Widget que muestra la vista previa de la cámara con controles de captura.
class CameraPreviewWidget extends StatefulWidget {
  final VoidCallback onCapture;
  final VoidCallback onClose;

  const CameraPreviewWidget({
    super.key,
    required this.onCapture,
    required this.onClose,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  final CameraService _cameraService = CameraService.instance;

  @override
  Widget build(BuildContext context) {
    if (!_cameraService.isInitialized ||
        _cameraService.controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildCameraPreview(),
          ),
        ),

        Positioned(
          top: 16,
          left: 16,
          child: _buildCircleButton(
            context,
            icon: Icons.close,
            onTap: widget.onClose,
          ),
        ),

        Positioned(
          top: 16,
          right: 16,
          child: _buildCircleButton(
            context,
            icon: Icons.flash_auto,
            onTap: () => _cameraService.toggleFlash(),
          ),
        ),

        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: widget.onCapture,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 130,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Enfoca el objeto y toca para capturar',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return CameraPreview(_cameraService.controller!);
  }

  Widget _buildCircleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black45,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
