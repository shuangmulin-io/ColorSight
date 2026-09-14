import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/plate_data.dart';
import '../../domain/models/test_mode.dart';
import '../../domain/models/test_result.dart';
import '../../domain/services/plate_generator.dart';
import '../../domain/services/scoring_service.dart';
import '../../../results/data/test_history_repository.dart';
import '../widgets/ishihara_plate_widget.dart';
import 'results_screen.dart';

class IshiharaTestScreen extends StatefulWidget {
  final TestBatteryMode mode;

  const IshiharaTestScreen({
    super.key,
    this.mode = TestBatteryMode.standard,
  });

  @override
  State<IshiharaTestScreen> createState() => _IshiharaTestScreenState();
}

class _IshiharaTestScreenState extends State<IshiharaTestScreen> {
  late final List<PlateData> _plates;
  final List<PlateResponse> _responses = [];
  int _currentIndex = 0;
  String _currentInput = '';
  final _repository = TestHistoryRepository();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _plates = PlateGenerator.generateBattery(mode: widget.mode);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_currentInput.length < 3) {
      setState(() {
        _currentInput += digit;
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _currentInput = '';
    });
  }

  void _onNothingPressed() {
    setState(() {
      _currentInput = 'nothing';
    });
    _submitAnswer();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    // Digits 0-9 (standard row & numpad)
    if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) {
      _onDigitPressed('0');
    } else if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
      _onDigitPressed('1');
    } else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) {
      _onDigitPressed('2');
    } else if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) {
      _onDigitPressed('3');
    } else if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) {
      _onDigitPressed('4');
    } else if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) {
      _onDigitPressed('5');
    } else if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6) {
      _onDigitPressed('6');
    } else if (key == LogicalKeyboardKey.digit7 || key == LogicalKeyboardKey.numpad7) {
      _onDigitPressed('7');
    } else if (key == LogicalKeyboardKey.digit8 || key == LogicalKeyboardKey.numpad8) {
      _onDigitPressed('8');
    } else if (key == LogicalKeyboardKey.digit9 || key == LogicalKeyboardKey.numpad9) {
      _onDigitPressed('9');
    }
    // Enter / Numpad Enter: submit current answer
    else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      if (_currentInput.isNotEmpty) {
        _submitAnswer();
      }
    }
    // Backspace: delete last character
    else if (key == LogicalKeyboardKey.backspace) {
      if (_currentInput.isNotEmpty) {
        setState(() {
          if (_currentInput == 'nothing' || _currentInput.length <= 1) {
            _currentInput = '';
          } else {
            _currentInput = _currentInput.substring(0, _currentInput.length - 1);
          }
        });
      }
    }
    // Escape or Delete: clear entire input
    else if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.delete) {
      _onClearPressed();
    }
    // Space or N/n: "Nothing / Unseen"
    else if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyN) {
      _onNothingPressed();
    }
  }

  void _submitAnswer() {
    final currentPlate = _plates[_currentIndex];
    final given = _currentInput.trim().toLowerCase();
    final normal = currentPlate.normalAnswer.trim().toLowerCase();

    final isCorrect = given == normal;

    _responses.add(PlateResponse(
      plateNumber: currentPlate.plateNumber,
      givenAnswer: given.isEmpty ? 'nothing' : given,
      normalAnswer: normal,
      isCorrect: isCorrect,
      cvdAnswer: currentPlate.cvdAnswer,
      protanAnswer: currentPlate.protanAnswer,
      deutanAnswer: currentPlate.deutanAnswer,
    ));

    if (_currentIndex < _plates.length - 1) {
      setState(() {
        _currentIndex++;
        _currentInput = '';
      });
    } else {
      _finishTest();
    }
  }

  Future<void> _finishTest() async {
    final result = ScoringService.evaluateAdultBattery(
      _responses,
      testMode: '${widget.mode.title} (${widget.mode.plateCount} Plates)',
    );
    await _repository.saveResult(result);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlate = _plates[_currentIndex];
    final progress = (_currentIndex + 1) / _plates.length;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Plate ${_currentIndex + 1} of ${_plates.length}'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final plateSize = (constraints.maxHeight * 0.34).clamp(180.0, 280.0);

            return Column(
              children: [
                const SizedBox(height: 8),
                // Instructions / Plate Title
                Text(
                  _currentIndex == 0
                      ? 'Demonstration Plate: What number do you see?'
                      : 'What number or pattern do you see inside the circle?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),

                // Plate CustomPainter
                Center(
                  child: IshiharaPlateWidget(
                    plate: currentPlate,
                    size: plateSize,
                  ),
                ),

                const SizedBox(height: 10),

                // Answer Display Box
                Container(
                  key: const Key('answer_display_box'),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _currentInput.isEmpty
                        ? 'Tap a number below'
                        : (_currentInput == 'nothing' ? 'Nothing / Unseen' : _currentInput),
                    key: const Key('answer_display_text'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: _currentInput.isEmpty ? AppColors.textMuted : AppColors.primary,
                    ),
                  ),
                ),

                const Spacer(),

                // Keypad & Action Buttons
                _buildKeypad(),
              ],
            );
          },
        ),
      ),
    ),
  );
}

  Widget _buildKeypad() {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDesktop)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Icon(Icons.keyboard_outlined, size: 14, color: AppColors.textMuted),
                  Text(
                    'Shortcuts: 0–9 to type • Enter to submit • Space/N for Nothing • ⌫ to delete',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          // Numbers 1-5
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _keypadButton(
                      label: '$i',
                      onTap: () => _onDigitPressed('$i'),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Numbers 6-0
          Row(
            children: [
              for (int i = 6; i <= 9; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _keypadButton(
                      label: '$i',
                      onTap: () => _onDigitPressed('$i'),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _keypadButton(
                    label: '0',
                    onTap: () => _onDigitPressed('0'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom Control Row: Clear, Nothing, Submit
          Row(
            children: [
              // Clear
              Expanded(
                flex: 1,
                child: Tooltip(
                  message: 'Backspace (⌫)',
                  child: OutlinedButton(
                    onPressed: _currentInput.isNotEmpty ? _onClearPressed : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Icon(Icons.backspace_outlined, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Nothing / Can't see
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: 'Space or N',
                  child: OutlinedButton.icon(
                    onPressed: _onNothingPressed,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.visibility_off_outlined, size: 18),
                    label: Text(isDesktop ? 'Nothing [Space]' : 'Nothing'),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Submit
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: 'Enter (↵)',
                  child: ElevatedButton.icon(
                    onPressed: _currentInput.isNotEmpty ? _submitAnswer : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(isDesktop ? 'Next [Enter]' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keypadButton({required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceElevated,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
