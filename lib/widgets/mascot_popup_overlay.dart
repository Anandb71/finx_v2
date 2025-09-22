import 'package:flutter/material.dart';
import '../services/mascot_manager_service.dart';

class MascotPopupOverlay extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const MascotPopupOverlay({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<MascotPopupOverlay> createState() => _MascotPopupOverlayState();
}

class _MascotPopupOverlayState extends State<MascotPopupOverlay>
    with TickerProviderStateMixin {
  final List<_PopupData> _activePopups = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showMascotPopup(MascotTrigger trigger) {
    final message = MascotManagerService.getMessageForContext(trigger);
    final popupData = _PopupData(
      id: DateTime.now().millisecondsSinceEpoch,
      message: message,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    setState(() {
      _activePopups.add(popupData);
    });

    // Auto-dismiss after duration
    Future.delayed(message.duration, () {
      dismissPopup(popupData.id);
    });

    // Start animation
    popupData.animationController.forward();
  }

  void dismissPopup(int id) {
    final popupData = _activePopups.firstWhere(
      (popup) => popup.id == id,
      orElse: () => _activePopups.first,
    );

    popupData.animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _activePopups.removeWhere((popup) => popup.id == id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Mascot popups
        ..._activePopups.map((popupData) {
          return Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MascotManagerService.buildMascotPopup(
              message: popupData.message,
              onDismiss: () => dismissPopup(popupData.id),
              animationController: popupData.animationController,
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _PopupData {
  final int id;
  final MascotMessage message;
  final AnimationController animationController;

  _PopupData({
    required this.id,
    required this.message,
    required this.animationController,
  });
}

// Global function to show mascot popup
void showMascotPopup(MascotTrigger trigger) {
  // This will be called from various parts of the app
  // The actual implementation will be handled by the overlay
}
