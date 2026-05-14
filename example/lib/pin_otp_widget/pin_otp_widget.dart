import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinOtpWidget extends StatelessWidget {
  const PinOtpWidget({
    super.key,
    required this.controller,
    this.length = 6,
    this.onComplete,
    this.onChange,
    this.onTap,
    this.validator,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onComplete;
  final ValueChanged<String>? onChange;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        );

    PinTheme box(Color border, Color fill) => PinTheme(
          width: 52,
          height: 60,
          textStyle: textStyle,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
            color: fill,
          ),
        );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Pinput(
          controller: controller,
          length: length,
          autofillHints: const [AutofillHints.oneTimeCode],
          keyboardType: TextInputType.number,
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: onComplete,
          onChanged: onChange,
          onTap: onTap,
          validator: validator,
          separatorBuilder: (_) => const SizedBox(width: 12),
          defaultPinTheme: box(cs.outline, cs.surfaceContainerHighest),
          focusedPinTheme:
              box(cs.primary, cs.primary.withValues(alpha: 0.08)),
          submittedPinTheme: box(cs.onSurface, Colors.transparent),
          errorPinTheme: box(cs.error, cs.error.withValues(alpha: 0.12)),
          cursor: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: 20,
                height: 2,
                color: cs.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
