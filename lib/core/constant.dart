import 'package:flutter/material.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';

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
  PomodoroModel.name: 0,
  ElaborationModel.name: 0,
};

/* ==================== Fields ========================= */
const minTitleLen = 1;
const maxTitleLen = 18;

/* =================== Notifications ================== */
const String urlLaunchActionId = 'id_1';
const String navigationActionId = 'id_3';
