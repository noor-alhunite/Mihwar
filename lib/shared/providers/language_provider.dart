import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('ar');

  void toggle() {
    state = state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
  }
}

final NotifierProvider<LanguageNotifier, Locale> languageProvider =
    NotifierProvider<LanguageNotifier, Locale>(LanguageNotifier.new);
