import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_music_stream/models/playlist.dart';
import 'package:my_music_stream/providers/music_provider.dart';
import 'package:my_music_stream/utils/constants.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  
  const PlaylistTile({
    Key? key,
    required this.playlist,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(4),
          image: playlist.coverImagePath != null
              ? DecorationImage(
                  image: AssetImage(playlist.coverImagePath!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: playlist.coverImagePath == null
            ? Icon(
                Icons.music_note,
                color: AppColors.lightGrey,
                size: 30,
              )
            : null,
      ),
      title: Text(
        playlist.name,
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Consumer<MusicProvider>(
        builder: (context, musicProvider, _) {
          final songCount = playlist.songIds.length;
          
          return Text(
            '$songCount ${songCount == 1 ? 'song' : 'songs'}',
            style: TextStyle(color: AppColors.lightGrey),
          );
        },
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.lightGrey,
      ),
      onTap: onTap,
    );
  }
}
