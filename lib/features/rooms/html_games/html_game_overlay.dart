import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tom_chat/l10n/l10n.dart';

/// Transparent modal route content: upper taps are consumed, never passed to the room.
class HtmlGameOverlay extends StatefulWidget {
  const HtmlGameOverlay({
    super.key,
    required this.child,
    required this.onLeave,
  });
  final Widget child;
  final VoidCallback onLeave;
  @override
  State<HtmlGameOverlay> createState() => HtmlGameOverlayState();
}

class HtmlGameOverlayState extends State<HtmlGameOverlay> {
  bool _confirming = false;
  bool _leaving = false;
  void requestClose() {
    if (!_confirming && !_leaving) setState(() => _confirming = true);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _leaving,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) requestClose();
    },
    child: Column(
      children: [
        Expanded(
          child: GestureDetector(
            key: const ValueKey('game-transparent-area'),
            behavior: HitTestBehavior.opaque,
            onTap: requestClose,
            child: const SizedBox.expand(),
          ),
        ),
        Expanded(
          child: Material(
            color: const Color(0xff102b30),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.child,
                  if (_confirming)
                    Positioned.fill(
                      child: ColoredBox(
                        color: const Color(0xff102b30),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.l10n.diceExit,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () =>
                                            setState(() => _confirming = false),
                                        child: Text(
                                          context.l10n.diceStay,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          setState(() => _leaving = true);
                                          // Rebuild PopScope before asking the navigator to pop this route.
                                          unawaited(
                                            WidgetsBinding.instance.endOfFrame
                                                .then((_) {
                                                  if (mounted) widget.onLeave();
                                                }),
                                          );
                                        },
                                        child: Text(context.l10n.diceLeave),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
