import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/widgets.dart';
import '../../../state/account_providers.dart';

class EditContactSheet extends ConsumerStatefulWidget {
  const EditContactSheet({super.key});

  @override
  ConsumerState<EditContactSheet> createState() => _EditContactSheetState();
}

class _EditContactSheetState extends ConsumerState<EditContactSheet> {
  late final TextEditingController _email;
  late final TextEditingController _secondary;

  @override
  void initState() {
    super.initState();
    final customer = ref.read(customerProvider);
    _email = TextEditingController(text: customer.email);
    final second = customer.secondaryPhone;
    _secondary = TextEditingController(text: second == null ? '' : '0${second.substring(4)}');
  }

  @override
  void dispose() {
    _email.dispose();
    _secondary.dispose();
    super.dispose();
  }

  bool get _emailValid => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());
  bool get _secondaryValid => _secondary.text.trim().isEmpty || normaliseKePhone(_secondary.text) != null;

  void _save() {
    ref
        .read(customerProvider.notifier)
        .updateContact(
          email: _email.text.trim(),
          secondaryPhone: _secondary.text.trim().isEmpty ? null : normaliseKePhone(_secondary.text),
        );
    Navigator.of(context).pop();
    showSfSnack(context, 'Contact details saved');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Edit contact details', style: t.headlineSmall),
        const Gap(Insets.xs),
        Text('To change your main mobile number, contact support so we can verify it.', style: t.bodySmall),
        const Gap(Insets.xl),
        Text('Email', style: t.titleSmall),
        const Gap(Insets.sm),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            errorText: _email.text.isNotEmpty && !_emailValid ? 'Enter a valid email address' : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const Gap(Insets.lg),
        Text('Second mobile (optional)', style: t.titleSmall),
        const Gap(Insets.sm),
        TextField(
          controller: _secondary,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]'))],
          decoration: InputDecoration(
            hintText: '07XX XXX XXX',
            errorText: _secondaryValid ? null : 'Enter a Kenyan mobile number',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const Gap(Insets.xl),
        SfButton(label: 'Save changes', onPressed: _emailValid && _secondaryValid ? _save : null),
      ],
    );
  }
}
