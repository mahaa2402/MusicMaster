import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_music_stream/providers/music_provider.dart';
import 'package:my_music_stream/utils/constants.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, _) {
        final isPlaying = musicProvider.playbackState == PlaybackState.playing;
        final isShuffleEnabled = musicProvider.isShuffleEnabled;
        final repeatMode = musicProvider.repeatMode;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle button
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: isShuffleEnabled ? AppColors.primary : AppColors.lightGrey,
                size: 24,
              ),
              onPressed: () {
                musicProvider.toggleShuffle();
              },
            ),
            
            // Previous button
            IconButton(
              icon: Icon(
                Icons.skip_previous,
                color: AppColors.white,
                size: 36,
              ),
              onPressed: () {
                musicProvider.playPrevious();
              },
            ),
            
            // Play/Pause button
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () {
                  if (isPlaying) {
                    musicProvider.pause();
                  } else {
                    musicProvider.play();
                  }
                },
              ),
            ),
            
            // Next button
            IconButton(
              icon: Icon(
                Icons.skip_next,
                color: AppColors.white,
                size: 36,
              ),
              onPressed: () {
                musicProvider.playNext();
              },
            ),
            
            // Repeat button
            IconButton(
              icon: Icon(
                repeatMode == RepeatMode.one
                    ? Icons.repeat_one
                    : Icons.repeat,
                color: repeatMode != RepeatMode.off
                    ? AppColors.primary
                    : AppColors.lightGrey,
                size: 24,
              ),
              onPressed: () {
                musicProvider.changeRepeatMode();
              },
            ),
          ],
        );
      },
    );
  }
}
