import 'package:flutter/material.dart';
import 'package:project_timer/anniversary_service.dart';
import 'anniversary_base_controller.dart';

// 新建详情页
class AnniversaryDetailPage extends StatefulWidget {
  final Anniversary ann;
  final String? imageAsset;
  const AnniversaryDetailPage({required this.ann, this.imageAsset, super.key});

  @override
  State<AnniversaryDetailPage> createState() => _AnniversaryDetailPageState();
}

class _AnniversaryDetailPageState
    extends AnniversaryBaseController<AnniversaryDetailPage> {
  bool _showChild = false;
  bool _showAppBar = true;
  static const int _imageFadeDurationMs = 400;
  static const int _textFadeDurationMs = 250;
  late Anniversary _currentAnn;
  late VoidCallback _annListener;

  @override
  void initState() {
    super.initState();
    _currentAnn = widget.ann;
    _annListener = () {
      final list = anniversaryService.anniversaries;
      final found = list.firstWhere(
        (a) => a.id == _currentAnn.id,
        orElse: () => _currentAnn,
      );
      if (mounted && found != _currentAnn) {
        setState(() => _currentAnn = found);
      }
    };
    anniversaryService.anniversariesNotifier.addListener(_annListener);
    _delayShowChild();
  }

  @override
  void dispose() {
    anniversaryService.anniversariesNotifier.removeListener(_annListener);
    super.dispose();
  }

  /// 延迟一段时间后显示自定义组件
  void _delayShowChild() async {
    await Future.delayed(const Duration(milliseconds: _imageFadeDurationMs));
    if (mounted) setState(() => _showChild = true);
  }

  /// 退场时先渐隐自定义控件和AppBar，再pop页面
  Future<void> _hideAndPop() async {
    if (_showAppBar) setState(() => _showAppBar = false);
    if (_showChild) {
      setState(() => _showChild = false);
      await Future.delayed(const Duration(milliseconds: _textFadeDurationMs));
    }
    if (mounted) Navigator.of(context).pop();
  }

  void deleteAnniversaryById(String id) {
    anniversaryService.removeAnniversaryById(id);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _hideAndPop();
        // 返回false，防止系统自动pop，由_hideAndPop控制
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Hero(
              tag: _currentAnn.id,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: _imageFadeDurationMs),
                curve: Curves.ease,
                child: Material(
                  color: Colors.transparent,
                  child: (_currentAnn.imageAsset != null &&
                          _currentAnn.imageAsset!.isNotEmpty)
                      ? Image.asset(
                          _currentAnn.imageAsset!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black.withOpacity(0.2),
                          colorBlendMode: BlendMode.darken,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[300]),
                        )
                      : Container(color: Colors.grey[200]),
                ),
              ),
            ),
            IgnorePointer(
              ignoring: !_showChild,
              child: AnimatedOpacity(
                opacity: _showChild ? 1.0 : 0.0,
                duration: const Duration(milliseconds: _textFadeDurationMs),
                curve: Curves.ease,
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 24, top: 64, right: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 180, // 约等于5行高度（26*1.2*5）
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(
                                _currentAnn.name,
                                style: const TextStyle(
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatDate(_currentAnn.date),
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weekdayString(_currentAnn.date),
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            daysDiffLabel(_currentAnn.date),
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildDaysDiffNumber(
                            daysDiffString(_currentAnn.date),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Orbitron-Regular',
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          //const SizedBox(height: 8),
                          Text(
                            dayUnitLabel(daysDiffString(_currentAnn.date)),
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_showAppBar)
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.white,
                        onPressed: _hideAndPop,
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await showAnniversarySheet(ann: _currentAnn);
                          } else if (value == 'delete') {
                            // 先关闭PopupMenu，再执行退场动画
                            Future.delayed(const Duration(milliseconds: 10),
                                () async {
                              deleteAnniversaryById(_currentAnn.id);
                              await _hideAndPop();
                            });
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: const [
                                Icon(Icons.edit,
                                    size: 20, color: Colors.greenAccent),
                                SizedBox(width: 12),
                                Text('修改数据'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete_outline,
                                    size: 20, color: Colors.redAccent),
                                SizedBox(width: 12),
                                Text('删除数据'),
                              ],
                            ),
                          ),
                        ],
                        elevation: 6,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
