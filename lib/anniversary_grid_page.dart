import 'package:flutter/material.dart';
import 'package:project_timer/anniversary_service.dart';
import 'package:project_timer/anniversary_detail_page.dart';
import 'package:project_timer/config_service.dart';
import 'anniversary_base_controller.dart';
import 'dart:io';

class AnniversaryGridPage extends StatefulWidget {
  const AnniversaryGridPage({super.key});

  static void Function(BuildContext context)? addAnniversary;

  @override
  State<AnniversaryGridPage> createState() => _AnniversaryGridPageState();
}

class _AnniversaryGridPageState
    extends AnniversaryBaseController<AnniversaryGridPage> {
  final AnniversaryService service = AnniversaryService();

  @override
  void initState() {
    super.initState();
    AnniversaryGridPage.addAnniversary = (ctx) => showAnniversarySheet();
  }

  @override
  void dispose() {
    if (AnniversaryGridPage.addAnniversary != null) {
      AnniversaryGridPage.addAnniversary = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppListSortMode>(
      valueListenable: anniversarySortModeNotifier,
      builder: (context, sortMode, _) {
        return ValueListenableBuilder<List<Anniversary>>(
          valueListenable: service.anniversariesNotifier,
          builder: (context, anniversaries, _) {
            if (anniversaries.isEmpty) {
              return noAnniversary(context);
            }
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
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final ann = sorted[index];
                return Container(
                  margin: const EdgeInsets.all(0), // 交由GridView的spacing控制
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 420),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  AnniversaryDetailPage(ann: ann),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Hero(
                      tag: ann.id,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 1,
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (ann.imageLocalPath != null ||
                                ann.imageNetworkUrl != null)
                              ann.imageLocalPath != null
                                  ? Image.file(
                                      File(ann.imageLocalPath!),
                                      fit: BoxFit.cover,
                                      color: Colors.black.withOpacity(0.2),
                                      colorBlendMode: BlendMode.darken,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Container(color: Colors.grey[300]),
                                    )
                                  : Image.network(
                                      ann.imageNetworkUrl!,
                                      fit: BoxFit.cover,
                                      color: Colors.black.withOpacity(0.2),
                                      colorBlendMode: BlendMode.darken,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Container(color: Colors.grey[300]),
                                    )
                            else
                              Container(color: Colors.grey[200]),
                            Container(
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        ann.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              offset: Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: buildDaysDiffNumber(
                                          daysDiffString(ann.date)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        daysDiffLabel(ann.date),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              offset: Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
