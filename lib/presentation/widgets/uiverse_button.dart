import 'package:flutter/material.dart';

class UiverseButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  final IconData icon;

  const UiverseButton({
    super.key,
    required this.onTap,
    required this.text,
    this.icon = Icons.arrow_forward,
  });

  @override
  State<UiverseButton> createState() => _UiverseButtonState();
}

class _UiverseButtonState extends State<UiverseButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEntered(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEntered(true),
      onExit: (_) => _onEntered(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF006BB3), // rgb(0 107 179)
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: _isHovered ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: Stack(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
                        child: Icon(widget.icon, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  // Shine effect
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Positioned(
                        left: -100 + (_controller.value * 300), // Moves from -100 to 200
                        top: 0,
                        bottom: 0,
                        width: 100,
                        child: child!,
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white54,
                            Colors.transparent,
                          ],
                          stops: [0.3, 0.5, 0.7],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
