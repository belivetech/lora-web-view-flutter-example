import 'dart:async';

import 'package:flutter/material.dart';

class PipController {
  final StreamController<PipState> _stateController =
      StreamController.broadcast();

  bool _isPipShowing = false;

  bool get isPipShowing => _isPipShowing;

  void close() {
    _isPipShowing = false;
    _stateController.add(PipState.none);
  }

  void minimize() {
    _isPipShowing = false;
    _stateController.add(PipState.minimize);
  }

  void full() {
    _isPipShowing = true;
    _stateController.add(PipState.full);
  }

  void dispose() {
    _stateController.close();
  }
}

class PipContainer extends StatefulWidget {
  const PipContainer({
    super.key,
    required this.content,
    required this.controller,
    required this.pipStateBuilder,
  });
  final Widget content;
  final PipController controller;
  final PipStateBuilder pipStateBuilder;
  @override
  State<PipContainer> createState() => _PipContainerState();
}

enum PipState {
  full,
  minimize,
  none,
}

typedef PipStateBuilder = Widget Function(BuildContext context, PipState state);

class _PipContainerState extends State<PipContainer> {
  PipState _state = PipState.none;
  double childDx = 100, childDy = 100;
  double topY = 21;
  double leftX = 16;
  StreamSubscription? stateListener;
  @override
  void initState() {
    super.initState();
    stateListener = widget.controller._stateController.stream.listen((state) {
      setState(() {
        _state = state;
      });
    });
  }

  @override
  void dispose() {
    stateListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.content,
        _buildBubble(context),
      ],
    );
  }

  Widget _buildBubble(BuildContext context) {
    switch (_state) {
      case PipState.minimize:
        return _buildDraggableWidget(
            context, widget.pipStateBuilder(context, _state));
      case PipState.full:
        return widget.pipStateBuilder(context, _state);
      case PipState.none:
      default:
        return const SizedBox();
    }
  }

  Widget _buildDraggableWidget(BuildContext context, Widget child) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      top: topY,
      left: leftX,
      child: GestureDetector(
        onPanUpdate: (details) {
          final dx = details.globalPosition.dx - childDx;
          final dy = details.globalPosition.dy - childDy;
          childDx = details.globalPosition.dx;
          childDy = details.globalPosition.dy;
          setState(() {
            topY = (topY + dy).clamp(0.0, double.infinity);
            leftX = (leftX + dx).clamp(0.0, double.infinity);
          });
        },
        child: SizedBox(
          width: 180,
          height: 320,
          child: child,
        ),
      ),
    );
  }
}
