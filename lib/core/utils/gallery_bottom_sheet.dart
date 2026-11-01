// ignore_for_file: unused_field

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/l10n/l10n.dart';

class GalleryBottomSheet extends StatefulWidget {
  final Function(File file, bool isVideo) onMediaSelected;

  final RequestType requestType;

  const GalleryBottomSheet({
    super.key,
    required this.onMediaSelected,
    this.requestType = RequestType.image,
  });

  @override
  State<GalleryBottomSheet> createState() => _GalleryBottomSheetState();
}

class _GalleryBottomSheetState extends State<GalleryBottomSheet>
    with SingleTickerProviderStateMixin {
  List<AssetEntity> _media = [];
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _currentAlbum;
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isSelectingAlbum = false;

  Map<String, AssetEntity?> _albumThumbnails = {};
  late TabController _tabController;
  RequestType _currentRequestType = RequestType.image;

  @override
  void initState() {
    super.initState();
    if (widget.requestType == RequestType.common) {
      _tabController = TabController(length: 2, vsync: this);
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) return;
        setState(() {
          _currentRequestType = _tabController.index == 0
              ? RequestType.image
              : RequestType.video;
          _isLoading = true;
        });
        _requestPermissionAndLoadMedia();
      });
    } else {
      _currentRequestType = widget.requestType;
    }
    _requestPermissionAndLoadMedia();
  }

  Future<void> _fetchAlbums() async {
    final albums = await PhotoManager.getAssetPathList(
      type: _currentRequestType,
      hasAll: true,
    );

    final thumbnails = <String, AssetEntity?>{};
    for (var album in albums) {
      final assetList = await album.getAssetListRange(start: 0, end: 1);
      thumbnails[album.id] = assetList.isNotEmpty ? assetList.first : null;
    }

    setState(() {
      _albums = albums;
      _albumThumbnails = thumbnails;
    });
  }

  Future<void> _requestPermissionAndLoadMedia() async {
    try {
      setState(() => _isLoading = true);

      final PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (ps.isAuth || ps == PermissionState.limited) {
        setState(() => _hasPermission = true);
        await _fetchAlbums();
        await _loadMedia();
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

  Future<void> _loadMedia([AssetPathEntity? selectedAlbum]) async {
    try {
      _albums = await PhotoManager.getAssetPathList(type: _currentRequestType);

      _currentAlbum = selectedAlbum ?? _albums.first;

      final media = await _currentAlbum!.getAssetListPaged(page: 0, size: 100);

      setState(() {
        _media = media;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              if (widget.requestType == RequestType.common)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    indicator: const BoxDecoration(),
                    labelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    labelColor: AppColors.primaryDark,
                    unselectedLabelColor: Colors.grey[600],
                    tabs: [
                      Tab(text: context.l10n.images),
                      Tab(text: context.l10n.videos),
                    ],
                  ),
                ),

              // Header with album switch
              Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSelectingAlbum = !_isSelectingAlbum;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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

              // Content
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
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryDark),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionDenied();
    }

    if (_media.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _media.length,
      itemBuilder: (context, index) {
        final asset = _media[index];
        return _buildMediaTile(asset);
      },
    );
  }

  Widget _buildAlbumsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        final album = _albums[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _isSelectingAlbum = false;
              _isLoading = true;
            });
            _loadMedia(album);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.folder, color: Colors.blueAccent),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${album.name} ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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

  Widget _buildMediaTile(AssetEntity asset) {
    return GestureDetector(
      onTap: () async {
        final file = await asset.file;
        if (file != null) {
          widget.onMediaSelected(file, asset.type == AssetType.video);
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<Uint8List?>(
                future: asset.thumbnailDataWithSize(ThumbnailSize(200, 200)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  }
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (asset.type == AssetType.video)
            Positioned(
              bottom: 6,
              right: 6,
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              context.l10n.permissionDenied,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              context.l10n.permissionsRequired,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await PhotoManager.openSetting();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF007AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                context.l10n.openSettings,
                style: TextStyle(color: Colors.white),
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
          Icon(Icons.photo, size: 60, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            context.l10n.noItemsFound,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            context.l10n.noImagesAvilableInGallery,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
