import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinAuthDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final Function(String) onPinEntered;
  final VoidCallback? onCancel;
  final bool isSetupMode; // For setting up new PIN vs authenticating

  const PinAuthDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPinEntered,
    this.onCancel,
    this.isSetupMode = false,
  });

  @override
  State<PinAuthDialog> createState() => _PinAuthDialogState();
}

class _PinAuthDialogState extends State<PinAuthDialog> {
  final List<String> _enteredPin = [];
  final int _pinLength = 6;
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // PIN Display
            _buildPinDisplay(),
            
            const SizedBox(height: 24),
            
            // Error Message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Number Pad
            _buildNumberPad(),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                if (_enteredPin.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _enteredPin.length == _pinLength ? _handlePinComplete : null,
                      child: Text(widget.isSetupMode && _isConfirming ? 'Confirm' : 'Continue'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 2: 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 3: 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 4: Empty, 0, Backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 60), // Empty space
            _buildNumberButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _addDigit(number),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          number,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return SizedBox(
      width: 60,
      height: 60,
      child: IconButton(
        onPressed: _enteredPin.isNotEmpty ? _removeLastDigit : null,
        icon: const Icon(Icons.backspace_outlined),
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  void _addDigit(String digit) {
    if (_enteredPin.length < _pinLength) {
      setState(() {
        _enteredPin.add(digit);
        _errorMessage = null;
      });
      
      // Auto-submit when PIN is complete
      if (_enteredPin.length == _pinLength) {
        _handlePinComplete();
      }
    }
  }

  void _removeLastDigit() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _errorMessage = null;
      });
    }
  }

  void _handlePinComplete() {
    final pin = _enteredPin.join();
    
    if (widget.isSetupMode) {
      if (!_isConfirming) {
        // First PIN entry - ask for confirmation
        setState(() {
          _confirmPin = pin;
          _isConfirming = true;
          _enteredPin.clear();
        });
      } else {
        // Confirming PIN
        if (pin == _confirmPin) {
          // PINs match - setup complete
          widget.onPinEntered(pin);
        } else {
          // PINs don't match - show error and restart
          setState(() {
            _errorMessage = 'PINs do not match. Please try again.';
            _enteredPin.clear();
            _isConfirming = false;
            _confirmPin = '';
          });
        }
      }
    } else {
      // Authentication mode - submit PIN
      widget.onPinEntered(pin);
    }
  }
}

class PatternAuthDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final Function(List<int>) onPatternEntered;
  final VoidCallback? onCancel;
  final bool isSetupMode;

  const PatternAuthDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPatternEntered,
    this.onCancel,
    this.isSetupMode = false,
  });

  @override
  State<PatternAuthDialog> createState() => _PatternAuthDialogState();
}

class _PatternAuthDialogState extends State<PatternAuthDialog> {
  final List<int> _selectedDots = [];
  List<int> _confirmPattern = [];
  bool _isConfirming = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Pattern Grid
            _buildPatternGrid(),
            
            const SizedBox(height: 24),
            
            // Error Message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                if (_selectedDots.length >= 4) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handlePatternComplete,
                      child: Text(widget.isSetupMode && _isConfirming ? 'Confirm' : 'Continue'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternGrid() {
    return Container(
      width: 200,
      height: 200,
      child: GestureDetector(
        onPanStart: (details) => _handlePanStart(details),
        onPanUpdate: (details) => _handlePanUpdate(details),
        onPanEnd: (details) => _handlePanEnd(details),
        child: CustomPaint(
          painter: PatternPainter(
            selectedDots: _selectedDots,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final isSelected = _selectedDots.contains(index);
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? Colors.white
                          : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    final dotIndex = _getDotIndexFromPosition(details.localPosition);
    if (dotIndex != null && !_selectedDots.contains(dotIndex)) {
      setState(() {
        _selectedDots.add(dotIndex);
        _errorMessage = null;
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final dotIndex = _getDotIndexFromPosition(details.localPosition);
    if (dotIndex != null && !_selectedDots.contains(dotIndex)) {
      setState(() {
        _selectedDots.add(dotIndex);
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_selectedDots.length >= 4) {
      _handlePatternComplete();
    }
  }

  int? _getDotIndexFromPosition(Offset position) {
    const dotSize = 60.0;
    const spacing = 20.0;
    
    for (int i = 0; i < 9; i++) {
      final row = i ~/ 3;
      final col = i % 3;
      final centerX = col * (dotSize + spacing) + dotSize / 2;
      final centerY = row * (dotSize + spacing) + dotSize / 2;
      
      final distance = (position - Offset(centerX, centerY)).distance;
      if (distance <= dotSize / 2) {
        return i;
      }
    }
    return null;
  }

  void _handlePatternComplete() {
    if (widget.isSetupMode) {
      if (!_isConfirming) {
        // First pattern entry - ask for confirmation
        setState(() {
          _confirmPattern = List.from(_selectedDots);
          _isConfirming = true;
          _selectedDots.clear();
        });
      } else {
        // Confirming pattern
        if (_listsEqual(_selectedDots, _confirmPattern)) {
          // Patterns match - setup complete
          widget.onPatternEntered(_selectedDots);
        } else {
          // Patterns don't match - show error and restart
          setState(() {
            _errorMessage = 'Patterns do not match. Please try again.';
            _selectedDots.clear();
            _isConfirming = false;
            _confirmPattern.clear();
          });
        }
      }
    } else {
      // Authentication mode - submit pattern
      widget.onPatternEntered(_selectedDots);
    }
  }

  bool _listsEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

class PatternPainter extends CustomPainter {
  final List<int> selectedDots;
  final Color color;

  PatternPainter({
    required this.selectedDots,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedDots.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < selectedDots.length - 1; i++) {
      final startDot = _getDotPosition(selectedDots[i], size);
      final endDot = _getDotPosition(selectedDots[i + 1], size);
      
      canvas.drawLine(startDot, endDot, paint);
    }
  }

  Offset _getDotPosition(int dotIndex, Size size) {
    const dotSize = 60.0;
    const spacing = 20.0;
    
    final row = dotIndex ~/ 3;
    final col = dotIndex % 3;
    final centerX = col * (dotSize + spacing) + dotSize / 2;
    final centerY = row * (dotSize + spacing) + dotSize / 2;
    
    return Offset(centerX, centerY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
