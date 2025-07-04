import 'package:flutter/material.dart';
import 'package:project_timer/anniversary_service.dart';
import 'package:project_timer/anniversary_detail_page.dart';
import 'package:project_timer/config_service.dart';
import 'anniversary_base_controller.dart';

class AnniversaryCarouselPage extends StatefulWidget {
  const AnniversaryCarouselPage({super.key});

  static void Function(BuildContext context)? addAnniversary;

  @override
  State<AnniversaryCarouselPage> createState() =>
      _AnniversaryCarouselPageState();
}

class _AnniversaryCarouselPageState
    extends AnniversaryBaseController<AnniversaryCarouselPage> {
  final PageController _pageController = PageController(viewportFraction: 0.96);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    AnniversaryCarouselPage.addAnniversary = (ctx) => showAnniversarySheet();
  }

  @override
  void dispose() {
    if (AnniversaryCarouselPage.addAnniversary != null) {
      AnniversaryCarouselPage.addAnniversary = null;
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() {
      _currentPage = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = AnniversaryService();
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
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: sorted.length,
                    onPageChanged: (i) => _onPageChanged(i),
                    itemBuilder: (context, index) {
                      final ann = sorted[index];
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double page = 0.0;
                          try {
                            if (_pageController.hasClients &&
                                _pageController.page != null) {
                              page = _pageController.page!;
                            } else {
                              page = _currentPage.toDouble();
                            }
                          } catch (_) {
                            page = _currentPage.toDouble();
                          }
                          final double delta = (page - index).clamp(-1.0, 1.0);
                          final double parallax = delta * 120; // 视差强度提升
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32, horizontal: 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 420),
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        AnniversaryDetailPage(
                                            ann: ann,
                                            imageAsset: ann.imageAsset),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
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
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 1,
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (ann.imageAsset != null &&
                                          ann.imageAsset!.isNotEmpty)
                                        Transform.translate(
                                          offset: Offset(parallax, 0),
                                          child: Image.asset(
                                            ann.imageAsset!,
                                            fit: BoxFit.cover,
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            colorBlendMode: BlendMode.darken,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Container(
                                                    color: Colors.grey[300]),
                                          ),
                                        )
                                      else
                                        Container(color: Colors.grey[200]),
                                      Container(
                                        padding: const EdgeInsets.all(32),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Text(
                                                  ann.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black54,
                                                        offset: Offset(1, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    fontSize: 28,
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
                                                  daysDiffString(ann.date),
                                                  style: TextStyle(
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black54,
                                                        offset: Offset(1, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    color: Colors.white,
                                                    fontFamily:
                                                        'Orbitron-Regular',
                                                    fontSize: 60,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  daysDiffLabel(ann.date),
                                                  style: const TextStyle(
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black54,
                                                        offset: Offset(1, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    fontSize: 20,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      if (sorted.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${_currentPage + 1} / ${sorted.length}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      LinearProgressIndicator(
                        value: sorted.length <= 1
                            ? 1.0
                            : (_currentPage + 1) / sorted.length,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300], // 亮色和暗色模式都用浅灰
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF222831), // 亮色和暗色模式都用主色
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
            );
          },
        );
      },
    );
  }
}
