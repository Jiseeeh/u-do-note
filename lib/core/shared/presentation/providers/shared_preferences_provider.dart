import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

@riverpod
class SharedPrefs extends _$SharedPrefs {
  @override
  void build() {
    return;
  }

  Future<Object?> get(String key) async {
    var prefs = await ref.watch(sharedPreferencesProvider.future);

    return prefs.get(key);
  }

  Future<void> clear() async {
    var prefs = await ref.watch(sharedPreferencesProvider.future);

    await prefs.clear();
  }

  Future<bool> has(String key) async {
    var prefs = await ref.watch(sharedPreferencesProvider.future);

    return prefs.containsKey(key);
  }

  Future<bool> remove(String key) async {
    var prefs = await ref.watch(sharedPreferencesProvider.future);

    return await prefs.remove(key);
  }

  Future<bool> set(String key, data) async {
    var prefs = await ref.watch(sharedPreferencesProvider.future);

    return await prefs.setString(key, data.toString());
  }
}
