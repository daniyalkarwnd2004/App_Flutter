import 'package:flutter/material.dart';

class SmsDisplayPage extends StatefulWidget {
  final String sender;
  final String body;

  const SmsDisplayPage({super.key, required this.sender, required this.body});

  @override
  State<SmsDisplayPage> createState() => _SmsDisplayPageState();
}

class _SmsDisplayPageState extends State<SmsDisplayPage> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _textPulseController;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    ));

    _entryController.forward();

    _textPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _textScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_textPulseController);

    _textFadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_textPulseController);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _textPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final senderTitleFontSize = size.width * 0.055;
    final senderFontSize = size.width * 0.047;
    final messageFontSize = size.width * 0.048;
    final paddingAll = size.width * 0.07;

    return Scaffold(
      backgroundColor: Colors.blue.shade100,  // پس زمینه آبی ملایم
      appBar: AppBar(
        title: const Text("New Message", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 24, 1, 70),
        foregroundColor: Colors.white, // رنگ آبی تیره
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade100.withOpacity(0.7),
                  Colors.blue.shade200.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _entryController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: _slideAnimation.value * size.height,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.only(top: size.height * 0.08, left: size.width * 0.06, right: size.width * 0.06, bottom: size.height * 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 25,
              color: Colors.white,
              shadowColor: const Color.fromARGB(100, 24, 1, 70),
              child: Padding(
                padding: EdgeInsets.all(paddingAll),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sender: ",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: senderTitleFontSize,
                        color: const Color.fromARGB(255, 24, 1, 70),
                        shadows: [
                          Shadow(
                            color: const Color.fromARGB(80, 24, 1, 70),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.sender,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: senderFontSize,
                        color: const Color.fromARGB(255, 24, 1, 70),
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      thickness: 1,
                      color: const Color.fromARGB(80, 24, 1, 70).withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            left: size.width * 0.08,
            right: size.width * 0.08,
            child: AnimatedBuilder(
              animation: _textPulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textFadeAnimation.value,
                  child: Transform.scale(
                    scale: _textScaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(60, 24, 1, 70),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color.fromARGB(40, 24, 1, 70),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50.withOpacity(0.6),
                      Colors.blue.shade100.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  widget.body,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: messageFontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color.fromARGB(255, 21, 15, 49),
                    height: 1.6,
                    shadows: [
                      Shadow(
                        color: const Color.fromARGB(99, 242, 241, 244).withOpacity(0.9),
                        blurRadius: 8,
                        offset: const Offset(1, 2),
                      ),
                      Shadow(
                        color: const Color.fromARGB(49, 115, 112, 120).withOpacity(0.6),
                        blurRadius: 14,
                        offset: const Offset(-1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
