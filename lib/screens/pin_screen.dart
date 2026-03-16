import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  final VoidCallback? onSuccess;

  const PinScreen({super.key, this.isSetup = false, this.onSuccess});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;
  bool _error = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _message = widget.isSetup ? 'Yangi PIN kiriting' : 'PIN kiriting';
  }

  void _onKey(String key) {
    setState(() => _error = false);

    if (_pin.length >= 4) return;
    final newPin = _pin + key;
    setState(() => _pin = newPin);

    if (newPin.length == 4) {
      _onComplete(newPin);
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _onComplete(String pin) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (widget.isSetup) {
      if (!_confirming) {
        setState(() {
          _confirming = true;
          _confirmPin = pin;
          _pin = '';
          _message = 'PINni qayta kiriting';
        });
      } else {
        if (pin == _confirmPin) {
          await context.read<ThemeProvider>().setPin(pin);
          if (mounted) {
            widget.onSuccess?.call();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN o\'rnatildi! ✓'), backgroundColor: AppTheme.primaryGreen),
            );
          }
        } else {
          setState(() {
            _error = true;
            _pin = '';
            _confirming = false;
            _message = 'PIN mos kelmadi. Qaytadan kiriting';
          });
        }
      }
    } else {
      final theme = context.read<ThemeProvider>();
      if (theme.checkPin(pin)) {
        widget.onSuccess?.call();
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _error = true;
          _pin = '';
          _message = 'Noto\'g\'ri PIN!';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: AppTheme.primaryGreen, size: 48),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'MONEY TRACKER',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              style: TextStyle(
                color: _error ? const Color(0xFFFF4757) : const Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ).animate(target: _error ? 1 : 0).shakeX(amount: 4),
            const SizedBox(height: 40),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: filled
                        ? (_error ? const Color(0xFFFF4757) : AppTheme.primaryGreen)
                        : const Color(0xFF1A2332),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: filled
                          ? (_error ? const Color(0xFFFF4757) : AppTheme.primaryGreen)
                          : const Color(0xFF2D3748),
                    ),
                  ),
                );
              }),
            ),

            const Spacer(),

            // Number pad
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: _buildKeypad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          children: ['1', '2', '3'].map((k) => Expanded(child: _KeyButton(label: k, onTap: () => _onKey(k)))).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['4', '5', '6'].map((k) => Expanded(child: _KeyButton(label: k, onTap: () => _onKey(k)))).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['7', '8', '9'].map((k) => Expanded(child: _KeyButton(label: k, onTap: () => _onKey(k)))).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            Expanded(child: _KeyButton(label: '0', onTap: () => _onKey('0'))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: GestureDetector(
                  onTap: _onDelete,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.backspace_rounded, color: Color(0xFF9CA3AF), size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF131929),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1A2332)),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
