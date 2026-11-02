import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'sf_button.dart';
import 'sf_card.dart';

Future<T?> showSfSheet<T>(BuildContext context, {required WidgetBuilder builder, bool dismissible = true}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    showDragHandle: dismissible,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(Insets.page, dismissible ? 0 : Insets.xxl, Insets.page, Insets.xl),
          child: builder(sheetContext),
        ),
      ),
    ),
  );
}

/// Confirmation shown after a payment, renewal or other completed action.
Future<void> showSuccessSheet(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'Done',
}) {
  return showSfSheet<void>(
    context,
    builder: (sheetContext) {
      final p = sheetContext.sf;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SfIconBox(
            icon: PhosphorIconsBold.check,
            size: 72,
            iconSize: 34,
            radius: 36,
            background: p.successSoft,
            foreground: p.success,
          ).animate().scale(begin: const Offset(0.6, 0.6), duration: 500.ms, curve: Curves.easeOutBack),
          const Gap(Insets.lg),
          Text(title, style: sheetContext.text.headlineSmall, textAlign: TextAlign.center),
          const Gap(6),
          Text(
            message,
            style: sheetContext.text.bodyMedium!.copyWith(color: p.inkMuted),
            textAlign: TextAlign.center,
          ),
          const Gap(Insets.xxl),
          SfButton(label: buttonLabel, onPressed: () => Navigator.of(sheetContext).pop()),
        ],
      );
    },
  );
}

void showSfSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
