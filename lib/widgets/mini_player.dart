import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_music_stream/providers/music_provider.dart';
import 'package:my_music_stream/screens/now_playing_screen.dart';
import 'package:my_music_stream/utils/constants.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Consumer<MusicProvider>(
          builder: (context, musicProvider, _) {
            final currentSong = musicProvider.currentSong;
            
            if (currentSong == null) {
              return const SizedBox.shrink();
            }
            
            final isPlaying = musicProvider.playbackState == PlaybackState.playing;
            
            return Row(
              children: [
                // Album art
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    currentSong.albumArt,
                    fit: BoxFit.cover,
                  ),
                ),
                
                // Song info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentSong.title,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentSong.artist,
                          style: TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Play/Pause button
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      musicProvider.pause();
                    } else {
                      musicProvider.play();
                    }
                  },
                ),
                
                // Next button
                IconButton(
                  icon: Icon(Icons.skip_next, color: AppColors.white),
                  onPressed: () {
                    musicProvider.playNext();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
