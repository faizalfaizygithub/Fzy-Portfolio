import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/contact_message.dart';
import '../providers/contact_provider.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    final sent = await context.read<ContactProvider>().submit(
          ContactMessage(
            name: _name.text.trim(),
            email: _email.text.trim(),
            subject: _subject.text.trim(),
            message: _message.text.trim(),
          ),
        );
    // Only clear the form after confirmed delivery; on failure the user
    // keeps what they typed.
    if (sent && mounted) {
      _formKey.currentState!.reset();
      for (final c in [_name, _email, _subject, _message]) {
        c.clear();
      }
      setState(() => _autovalidate = AutovalidateMode.disabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select<ContactProvider, ContactStatus>((p) => p.status);
    final sending = status == ContactStatus.sending;

    return AnimatedSwitcher(
      duration: AppDurations.medium,
      switchInCurve: AppCurves.smooth,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: status == ContactStatus.success
          ? _SuccessView(onReset: context.read<ContactProvider>().reset)
          : Form(
              key: _formKey,
              autovalidateMode: _autovalidate,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final name = _Field(
                          controller: _name,
                          label: 'Name',
                          icon: Icons.person_outline_rounded,
                          validator: ContactValidators.name,
                          autofill: const [AutofillHints.name],
                          enabled: !sending,
                        );
                        final email = _Field(
                          controller: _email,
                          label: 'Email',
                          icon: Icons.alternate_email_rounded,
                          validator: ContactValidators.email,
                          keyboard: TextInputType.emailAddress,
                          autofill: const [AutofillHints.email],
                          enabled: !sending,
                        );
                        if (constraints.maxWidth < 520) {
                          return Column(
                            children: [name, const SizedBox(height: AppSpacing.md), email],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: name),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: email),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _subject,
                      label: 'Subject',
                      icon: Icons.short_text_rounded,
                      validator: ContactValidators.subject,
                      enabled: !sending,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _message,
                      label: 'Message',
                      icon: Icons.chat_bubble_outline_rounded,
                      validator: ContactValidators.message,
                      maxLines: 6,
                      keyboard: TextInputType.multiline,
                      action: TextInputAction.newline,
                      enabled: !sending,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedSize(
                      duration: AppDurations.medium,
                      curve: AppCurves.smooth,
                      child: status == ContactStatus.failure
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _ErrorBanner(
                                message: context.read<ContactProvider>().error ??
                                    'Your message couldn\'t be sent.',
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    AppButton(
                      label: sending ? 'Sending…' : 'Send Message',
                      icon: Icons.send_rounded,
                      expand: true,
                      loading: sending,
                      onPressed: sending ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    required this.enabled,
    this.maxLines = 1,
    this.keyboard,
    this.action = TextInputAction.next,
    this.autofill,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboard;
  final TextInputAction action;
  final Iterable<String>? autofill;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : 1,
      keyboardType: keyboard,
      textInputAction: action,
      autofillHints: autofill,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: maxLines > 1
            ? Padding(
                padding: const EdgeInsets.only(bottom: 96),
                child: Icon(icon, size: 19, color: AppColors.textMuted),
              )
            : Icon(icon, size: 19, color: AppColors.textMuted),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: theme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  GestureDetector(
                    onTap: () => LinkLauncher.email(),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        'Email me directly →',
                        style: theme.labelLarge?.copyWith(color: AppColors.highlight, fontSize: 13.5),
                      ),
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

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppDurations.slow,
              curve: Curves.elasticOut,
              builder: (context, t, child) => Transform.scale(scale: t, child: child),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 38),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Message sent!', style: theme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Thanks for reaching out. I\'ll get back to you as soon as I can.',
              style: theme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Send another message',
              variant: AppButtonVariant.outline,
              compact: true,
              onPressed: onReset,
            ),
          ],
        ),
      ),
    );
  }
}
