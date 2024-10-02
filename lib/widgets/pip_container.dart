import 'dart:async';

import 'package:flutter/material.dart';

class PipController {
  final StreamController<PipState> _stateController =
      StreamController.broadcast();

  void close() {
    _stateController.add(PipState.none);
  }

  void minimize() {
    _stateController.add(PipState.minimize);
  }

  void full() {
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

  Widget _bubbleWraper(BuildContext context, Widget child) {
    return Container(
      key: const ValueKey("bubble-pip"),
      child: child,
    );
  }

  Widget _buildBubble(BuildContext context) {
    switch (_state) {
      case PipState.minimize:
        return _bubbleWraper(
            context,
            _buildDraggableWidget(
                context, widget.pipStateBuilder(context, _state)));
      case PipState.full:
        return _bubbleWraper(
            context,
            AnimatedPositioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              duration: const Duration(milliseconds: 100),
              child: widget.pipStateBuilder(context, _state),
            ));
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
          width: 150,
          height: 250,
          child: child,
        ),
      ),
    );
  }
}
