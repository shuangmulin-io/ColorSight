import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/test_mode.dart';
import 'ishihara_test_screen.dart';

class PreTestCheckScreen extends StatefulWidget {
  const PreTestCheckScreen({super.key});

  @override
  State<PreTestCheckScreen> createState() => _PreTestCheckScreenState();
}

class _PreTestCheckScreenState extends State<PreTestCheckScreen> {
  TestBatteryMode _selectedMode = TestBatteryMode.standard;
  bool _nightShiftOff = false;
  bool _vividModeOff = false;
  bool _brightnessMax = false;
  bool _glareChecked = false;

  bool get _allChecked =>
      _nightShiftOff && _vividModeOff && _brightnessMax && _glareChecked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Calibration Check'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Critical Alert Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Required Screen Preparation',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'The screening relies on exact RGB pixel rendering. Software color shifts will distort your test outcome.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Please complete and confirm all 4 checks:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Check Item 1: Night Shift / Blue Light
                    _buildCheckCard(
                      icon: Icons.nightlight_round,
                      title: 'Disable Night Shift / Blue-Light Filter',
                      description:
                          'Turn off iOS Night Shift, True Tone, Android Night Light, f.lux, or eye comfort shields.',
                      value: _nightShiftOff,
                      onChanged: (val) => setState(() => _nightShiftOff = val ?? false),
                    ),

                    const SizedBox(height: 12),

                    // Check Item 2: Vivid Color Mode
                    _buildCheckCard(
                      icon: Icons.palette_outlined,
                      title: 'Standard Color Profile (No "Vivid" Mode)',
                      description:
                          'Ensure your device display profile is set to Natural or Standard, not Vivid or Saturated.',
                      value: _vividModeOff,
                      onChanged: (val) => setState(() => _vividModeOff = val ?? false),
                    ),

                    const SizedBox(height: 12),

                    // Check Item 3: 100% Brightness
                    _buildCheckCard(
                      icon: Icons.brightness_high_rounded,
                      title: 'Set Screen Brightness to Maximum',
                      description:
                          'Set your phone/monitor brightness to 100% so subtle hue contrasts are clearly perceptible.',
                      value: _brightnessMax,
                      onChanged: (val) => setState(() => _brightnessMax = val ?? false),
                    ),

                    const SizedBox(height: 12),

                    // Check Item 4: Ambient Glare
                    _buildCheckCard(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Check for Screen Reflections & Glare',
                      description:
                          'Avoid holding the phone under direct sunlight or harsh overhead lights that wash out plates.',
                      value: _glareChecked,
                      onChanged: (val) => setState(() => _glareChecked = val ?? false),
                    ),

                    const SizedBox(height: 20),

                    // Quick "Select All" helper
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            final toggle = !_allChecked;
                            _nightShiftOff = toggle;
                            _vividModeOff = toggle;
                            _brightnessMax = toggle;
                            _glareChecked = toggle;
                          });
                        },
                        icon: Icon(
                          _allChecked ? Icons.remove_done_rounded : Icons.done_all_rounded,
                          size: 18,
                        ),
                        label: Text(_allChecked ? 'Uncheck All' : 'Confirm All Checks'),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Choose Test Length:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: TestBatteryMode.values.map((mode) {
                        final isSelected = mode == _selectedMode;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMode = mode),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      mode.badge,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? const Color(0xFF0F172A) : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    mode.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${mode.plateCount} Plates',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _allChecked
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IshiharaTestScreen(mode: _selectedMode),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    _allChecked
                        ? "Begin ${_selectedMode.title} (${_selectedMode.plateCount} Plates)"
                        : 'Confirm All 4 Checks to Continue',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value ? AppColors.surfaceElevated : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.border,
            width: value ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              checkColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: value ? AppColors.primary : AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: value ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
