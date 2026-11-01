import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/l10n/l10n.dart';

class AudioPickerBottomSheet extends StatefulWidget {
  final Function(File file) onAudioSelected;

  const AudioPickerBottomSheet({super.key, required this.onAudioSelected});

  @override
  State<AudioPickerBottomSheet> createState() => _AudioPickerBottomSheetState();
}

class _AudioPickerBottomSheetState extends State<AudioPickerBottomSheet> {
  List<AssetEntity> _audios = [];
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _currentAlbum;

  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isSelectingAlbum = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadAudios();
  }

  Future<void> _requestPermissionAndLoadAudios() async {
    try {
      setState(() => _isLoading = true);

      final ps = await PhotoManager.requestPermissionExtend(
        requestOption: PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.audio,
            mediaLocation: false,
          ),
        ),
      );

      if (ps.isAuth || ps == PermissionState.limited) {
        setState(() => _hasPermission = true);
        await _fetchAlbums();
        await _loadAudios();
        return;
      }

      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAlbums() async {
    // NOTE: photo_manager يدعم audio ضمن RequestType
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
      hasAll: true,
    );

    setState(() {
      _albums = albums;
      _currentAlbum = albums.isNotEmpty ? albums.first : null;
    });
  }

  Future<void> _loadAudios([AssetPathEntity? selectedAlbum]) async {
    try {
      // ضمان توفر الألبومات
      if (_albums.isEmpty) {
        await _fetchAlbums();
      }
      if (_albums.isEmpty) {
        setState(() {
          _audios = [];
          _isLoading = false;
        });
        return;
      }

      _currentAlbum = selectedAlbum ?? _currentAlbum ?? _albums.first;

      final list = await _currentAlbum!.getAssetListPaged(page: 0, size: 300);

      // تأكيد أنها Audios فقط (احتياطًا)
      final audiosOnly = list.where((e) => e.type == AssetType.audio).toList();

      setState(() {
        _audios = audiosOnly;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header (Albums switch)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSelectingAlbum = !_isSelectingAlbum;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentAlbum?.name ?? context.l10n.recent,
                          style: Theme.of(context).textTheme.displayMedium!
                              .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Icon(
                          _isSelectingAlbum
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: _isSelectingAlbum
                    ? _buildAlbumsList()
                    : _buildContent(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return _buildPermissionDenied();
    }

    if (_audios.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _audios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final asset = _audios[index];
        return _buildAudioTile(asset);
      },
    );
  }

  Widget _buildAlbumsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        final album = _albums[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _isSelectingAlbum = false;
              _isLoading = true;
            });
            _loadAudios(album);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.folder, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    album.name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioTile(AssetEntity asset) {
    return InkWell(
      onTap: () async {
        final file = await asset.file; // قد يرجع null إذا ما عنده صلاحية/مشكلة
        if (file != null) {
          widget.onAudioSelected(file);
          return;
        }

        // fallback: بعض الأجهزة تحتاج originFile
        final origin = await asset.originFile;
        if (origin != null) {
          widget.onAudioSelected(origin);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.music_note, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: FutureBuilder<String>(
                future: asset.titleAsync,
                builder: (context, snap) {
                  final title = (snap.data?.trim().isNotEmpty ?? false)
                      ? snap.data!.trim()
                      : 'Audio';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(asset.duration),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final ss = s.toString().padLeft(2, '0');
    return '$m:$ss';
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              context.l10n.permissionDenied,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.permissionsRequired,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await PhotoManager.openSetting();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                context.l10n.openSettings,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            context.l10n.noItemsFound,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'No audio files available on this device.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
