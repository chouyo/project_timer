import 'package:flutter/material.dart';
import 'package:project_timer/anniversary_service.dart';
import 'package:project_timer/config_service.dart';
import 'anniversary_detail_page.dart';
import 'anniversary_base_controller.dart';
import 'dart:io';

class AnniversaryPage extends StatefulWidget {
  const AnniversaryPage({super.key});

  static void Function(BuildContext context)? addAnniversary;

  @override
  State<AnniversaryPage> createState() => _AnniversaryPageState();
}

class _AnniversaryPageState extends AnniversaryBaseController<AnniversaryPage> {
  @override
  void initState() {
    super.initState();
    AnniversaryPage.addAnniversary = (ctx) => showAnniversarySheet();
  }

  @override
  void dispose() {
    if (AnniversaryPage.addAnniversary != null) {
      AnniversaryPage.addAnniversary = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // 交由主结构管理
      backgroundColor: Colors.transparent,
      body: ValueListenableBuilder<AppListSortMode>(
        valueListenable: anniversarySortModeNotifier,
        builder: (context, sortMode, _) {
          return ValueListenableBuilder<List<Anniversary>>(
            valueListenable: anniversaryService.anniversariesNotifier,
            builder: (context, anniversaries, _) {
              if (anniversaries.isEmpty) {
                return noAnniversary(context);
              }
              // 本地排序，保证UI响应
              final sorted = List<Anniversary>.from(anniversaries);
              sorted.sort((a, b) {
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
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final ann = sorted[index];
                  return Dismissible(
                    key: ValueKey(ann.id),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                          const Icon(Icons.edit, color: Colors.white, size: 28),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.delete,
                          color: Colors.white, size: 28),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        await showAnniversarySheet(ann: ann);
                        return false; // 不真正滑走
                      }
                      return direction == DismissDirection.endToStart;
                    },
                    onDismissed: (_) {
                      deleteAnniversary(index);
                    },
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    AnniversaryDetailPage(ann: ann),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return child; // 只保留Hero动画，无滑动过渡
                            },
                          ),
                        );
                      },
                      child: Hero(
                        tag: ann.id,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;
                            final cardColor = isDark
                                ? Color.alphaBlend(
                                    Colors.black.withOpacity(0.5), Colors.white)
                                : Colors.white;
                            return Card(
                              color: cardColor,
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: (ann.imageLocalPath != null ||
                                            ann.imageNetworkUrl != null)
                                        ? ann.imageLocalPath != null
                                            ? Image.file(
                                                File(ann.imageLocalPath!),
                                                fit: BoxFit.cover,
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                colorBlendMode:
                                                    BlendMode.darken,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                        color:
                                                            Colors.grey[300]),
                                              )
                                            : Image.network(
                                                ann.imageNetworkUrl!,
                                                fit: BoxFit.cover,
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                colorBlendMode:
                                                    BlendMode.darken,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                        color:
                                                            Colors.grey[300]),
                                              )
                                        : Container(color: Colors.grey[200]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // 左侧：名称和日期
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth:
                                                                  140), // 最大宽度可自定义
                                                      child: Text(
                                                        ann.name,
                                                        style: const TextStyle(
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors
                                                                  .black54,
                                                              offset:
                                                                  Offset(1, 1),
                                                              blurRadius: 2,
                                                            ),
                                                          ],
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth:
                                                                  140), // 可自定义最大宽度
                                                      child: Text(
                                                        daysDiffLabel(ann.date),
                                                        style: const TextStyle(
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors
                                                                  .black54,
                                                              offset:
                                                                  Offset(1, 1),
                                                              blurRadius: 2,
                                                            ),
                                                          ],
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                '${formatDate(ann.date)} ${weekdayString(ann.date)}',
                                                style: TextStyle(
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black54,
                                                      offset: Offset(1, 1),
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 右侧只保留数字部分
                                        Container(
                                          alignment: Alignment.centerRight,
                                          height: 48,
                                          constraints: const BoxConstraints(
                                              maxWidth: 100),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                buildDaysDiffNumber(
                                                    daysDiffString(ann.date)),
                                                Text(
                                                  dayUnitLabel(
                                                      daysDiffString(ann.date)),
                                                  style: const TextStyle(
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black54,
                                                        offset: Offset(1, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
