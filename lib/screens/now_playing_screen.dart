import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_music_stream/models/song.dart';
import 'package:my_music_stream/providers/music_provider.dart';
import 'package:my_music_stream/providers/auth_provider.dart';
import 'package:my_music_stream/providers/queue_provider.dart';
import 'package:my_music_stream/widgets/player_controls.dart';
import 'package:my_music_stream/utils/constants.dart';
import 'package:my_music_stream/utils/helpers.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, _) {
        final currentSong = musicProvider.currentSong;
        
        if (currentSong == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Text(
                'No song playing',
                style: TextStyle(color: AppColors.lightGrey, fontSize: 18),
              ),
            ),
          );
        }
        
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Now Playing',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.queue_music, color: AppColors.white),
                        onPressed: () {
                          _showQueueBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ),
                
                // Album art
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        currentSong.albumArt,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                // Song info
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Title and like button
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSong.title,
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentSong.artist,
                                    style: TextStyle(
                                      color: AppColors.lightGrey,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                final isLiked = authProvider.currentUser?.likedSongIds
                                    .contains(currentSong.id) ?? false;
                                
                                return IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? AppColors.primary : AppColors.lightGrey,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    authProvider.toggleLikedSong(currentSong.id);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Progress bar
                        Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 14,
                                ),
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: AppColors.darkGrey,
                                thumbColor: AppColors.primary,
                                overlayColor: AppColors.primary.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: musicProvider.position.inSeconds.toDouble(),
                                min: 0,
                                max: musicProvider.duration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  musicProvider.seekTo(Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatDuration(musicProvider.position),
                                    style: TextStyle(
                                      color: AppColors.lightGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    formatDuration(musicProvider.duration),
                                    style: TextStyle(
                                      color: AppColors.lightGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Player controls
                        const PlayerControls(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQueueBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Playing Queue',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.clear_all, color: AppColors.primary),
                        label: Text(
                          'Clear',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        onPressed: () {
                          Provider.of<QueueProvider>(context, listen: false).clearQueue();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                
                // Queue list
                Expanded(
                  child: Consumer2<QueueProvider, MusicProvider>(
                    builder: (context, queueProvider, musicProvider, _) {
                      final queue = queueProvider.queue;
                      
                      if (queue.isEmpty) {
                        return Center(
                          child: Text(
                            'Queue is empty',
                            style: TextStyle(color: AppColors.lightGrey),
                          ),
                        );
                      }
                      
                      return ReorderableListView.builder(
                        scrollController: scrollController,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: queue.length,
                        onReorder: (oldIndex, newIndex) {
                          // Handle the reordering logic
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          queueProvider.moveSongInQueue(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final songId = queue[index];
                          final song = musicProvider.songs.firstWhere(
                            (s) => s.id == songId,
                            orElse: () => Song(
                              id: 'unknown',
                              title: 'Unknown Song',
                              artist: 'Unknown Artist',
                              albumArt: 'assets/images/album1.jpg',
                              assetPath: 'assets/audio/song1.mp3',
                              duration: 0,
                              album: 'Unknown Album',
                            ),
                          );
                          
                          // No need to check for null since we provide a default Song now
                          
                          final isCurrentSong = index == queueProvider.currentIndex;
                          
                          return ListTile(
                            key: ValueKey(songId),
                            leading: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.asset(
                                    song.albumArt,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (isCurrentSong)
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                color: isCurrentSong
                                    ? AppColors.primary
                                    : AppColors.white,
                                fontWeight: isCurrentSong
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: TextStyle(color: AppColors.lightGrey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: AppColors.lightGrey),
                              onPressed: () {
                                queueProvider.removeFromQueue(index);
                              },
                            ),
                            onTap: () {
                              if (!isCurrentSong) {
                                // Play this song from the queue
                                musicProvider.playSong(song);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
