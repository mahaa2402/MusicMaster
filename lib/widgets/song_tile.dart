import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_music_stream/models/song.dart';
import 'package:my_music_stream/providers/auth_provider.dart';
import 'package:my_music_stream/providers/music_provider.dart';
import 'package:my_music_stream/providers/playlist_provider.dart';
import 'package:my_music_stream/utils/constants.dart';
import 'package:my_music_stream/utils/helpers.dart';

class SongTile extends StatelessWidget {
  final Song song;
  
  const SongTile({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          song.albumArt,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            song.artist,
            style: TextStyle(color: AppColors.lightGrey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 8),
          Text(
            '• ${formatDuration(Duration(seconds: song.duration))}',
            style: TextStyle(color: AppColors.lightGrey, fontSize: 12),
          ),
        ],
      ),
      trailing: _buildTrailingActions(context),
      onTap: () {
        // Play the selected song
        final musicProvider = Provider.of<MusicProvider>(context, listen: false);
        musicProvider.playSong(song);
        
        // Add to recently played
        Provider.of<AuthProvider>(context, listen: false).addToRecentlyPlayed(song.id);
      },
    );
  }
  
  Widget _buildTrailingActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like button
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final isLiked = authProvider.currentUser?.likedSongIds.contains(song.id) ?? false;
            
            return IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? AppColors.primary : AppColors.lightGrey,
                size: 20,
              ),
              onPressed: () {
                authProvider.toggleLikedSong(song.id);
                
                // Update the "Liked Songs" playlist
                final likedSongIds = authProvider.currentUser?.likedSongIds ?? [];
                Provider.of<PlaylistProvider>(context, listen: false)
                    .syncLikedSongs(likedSongIds);
              },
            );
          },
        ),
        
        // More options
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColors.lightGrey),
          onPressed: () {
            _showOptionsBottomSheet(context);
          },
        ),
      ],
    );
  }
  
  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Song info header
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  song.albumArt,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                song.title,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
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
            ),
            const Divider(height: 1, color: Colors.grey),
            
            // Add to queue
            ListTile(
              leading: Icon(Icons.queue_music, color: AppColors.white),
              title: Text(
                'Add to Queue',
                style: TextStyle(color: AppColors.white),
              ),
              onTap: () {
                Provider.of<MusicProvider>(context, listen: false).playSong(song);
                Navigator.pop(context);
              },
            ),
            
            // Add to playlist
            ListTile(
              leading: Icon(Icons.playlist_add, color: AppColors.white),
              title: Text(
                'Add to Playlist',
                style: TextStyle(color: AppColors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(context);
              },
            ),
            
            // View artist
            ListTile(
              leading: Icon(Icons.person, color: AppColors.white),
              title: Text(
                'View Artist',
                style: TextStyle(color: AppColors.white),
              ),
              onTap: () {
                // Filter songs by this artist
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Showing songs by ${song.artist}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            // View album
            ListTile(
              leading: Icon(Icons.album, color: AppColors.white),
              title: Text(
                'View Album',
                style: TextStyle(color: AppColors.white),
              ),
              onTap: () {
                // Filter songs by this album
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Showing songs from ${song.album}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
  
  void _showAddToPlaylistDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Add to Playlist',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Consumer<PlaylistProvider>(
                builder: (context, playlistProvider, _) {
                  final playlists = playlistProvider.playlists;
                  
                  return ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      final isInPlaylist = playlist.songIds.contains(song.id);
                      
                      return ListTile(
                        title: Text(
                          playlist.name,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: isInPlaylist ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isInPlaylist
                            ? Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          if (isInPlaylist) {
                            playlistProvider.removeSongFromPlaylist(
                              playlist.id,
                              song.id,
                            );
                          } else {
                            playlistProvider.addSongToPlaylist(
                              playlist.id,
                              song.id,
                            );
                          }
                          
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isInPlaylist
                                    ? 'Removed from ${playlist.name}'
                                    : 'Added to ${playlist.name}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
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
  }
}
