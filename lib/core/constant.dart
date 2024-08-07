import 'package:flutter/material.dart';

import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';

/* ==================== Localizations ==================== */
const Locale defaultLocale = Locale('en');
const Locale filLocale = Locale('fil');
const List<Locale> supportedLocales = [defaultLocale, filLocale];

/* ==================== Notebook ========================= */
const defaultTechniquesUsage = {
  LeitnerSystemModel.name: 0,
  FeynmanModel.name: 0,
  PomodoroModel.name: 0
};
