import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:project_timer/config_service.dart'; // Import your ConfigService

class AnniversaryService {
  static final AnniversaryService _instance = AnniversaryService._internal();
  factory AnniversaryService() => _instance;
  AnniversaryService._internal();

  final ValueNotifier<List<Anniversary>> anniversariesNotifier =
      ValueNotifier([]);
  List<Anniversary> get anniversaries => anniversariesNotifier.value;

  void printAnniversaries([String tag = '']) {
    const blue = '\x1B[34m';
    const reset = '\x1B[0m';
    debugPrint('$blue--- Anniversaries $tag ---$reset');
    for (final a in anniversaries) {
      debugPrint(
          '$blue id: ${a.id}, name: ${a.name}, date: ${a.date.toIso8601String()}, createdAt: ${a.createdAt.toIso8601String()}, updatedAt: ${a.updatedAt.toIso8601String()} $reset');
    }
    debugPrint('${blue}--------------------------$reset');
  }

  Future<void> loadAnniversaries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('anniversaries') ?? [];
    List<Anniversary> loaded =
        list.map((e) => Anniversary.fromJson(jsonDecode(e))).toList();
    // 排序
    final sortMode = ConfigService().anniversarySortMode;
    loaded.sort((a, b) {
      switch (sortMode) {
        case AppListSortMode.createdAsc:
          return a.createdAt.compareTo(b.createdAt);
        case AppListSortMode.createdDesc:
          return b.createdAt.compareTo(a.createdAt);
        case AppListSortMode.updatedAsc:
          return a.updatedAt.compareTo(b.updatedAt);
        case AppListSortMode.updatedDesc:
          return b.updatedAt.compareTo(a.updatedAt);
        case AppListSortMode.dateAsc:
          return a.date.compareTo(b.date);
        case AppListSortMode.dateDesc:
          return b.date.compareTo(a.date);
      }
    });
    anniversariesNotifier.value = loaded;
    printAnniversaries('load');
  }

  Future<void> saveAnniversaries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = anniversaries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('anniversaries', list);
    printAnniversaries('save');
  }

  void addAnniversary(Anniversary ann) {
    anniversariesNotifier.value = List.from(anniversaries)..add(ann);
    saveAnniversaries();
    printAnniversaries('add');
  }

  void removeAnniversary(int index) {
    anniversariesNotifier.value = List.from(anniversaries)..removeAt(index);
    saveAnniversaries();
    printAnniversaries('remove');
  }

  void removeAnniversaryById(String id) {
    anniversariesNotifier.value = List.from(anniversaries)
      ..removeWhere((a) => a.id == id);
    saveAnniversaries();
    printAnniversaries('removeById');
  }
}

class Anniversary {
  final String id;
  final String name;
  final DateTime date;
  final String? imageLocalPath; // 本地文件路径
  final String? imageNetworkUrl; // 网络图片URL
  final DateTime createdAt;
  final DateTime updatedAt;
  Anniversary({
    String? id,
    required this.name,
    required this.date,
    this.imageLocalPath,
    this.imageNetworkUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        if (imageLocalPath != null) 'imageLocalPath': imageLocalPath,
        if (imageNetworkUrl != null) 'imageNetworkUrl': imageNetworkUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
  factory Anniversary.fromJson(Map<String, dynamic> json) => Anniversary(
        id: json['id'],
        name: json['name'],
        date: DateTime.parse(json['date']),
        imageLocalPath: json['imageLocalPath'],
        imageNetworkUrl: json['imageNetworkUrl'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
}
