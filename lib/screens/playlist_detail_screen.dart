import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_music_stream/models/playlist.dart';
import 'package:my_music_stream/models/song.dart';
import 'package:my_music_stream/providers/music_provider.dart';
import 'package:my_music_stream/providers/playlist_provider.dart';
import 'package:my_music_stream/providers/queue_provider.dart';
import 'package:my_music_stream/widgets/song_tile.dart';
import 'package:my_music_stream/utils/constants.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  final List<Song>? songs; // Optional list of songs (for "Liked Songs" tab)
  
  const PlaylistDetailScreen({
    Key? key,
    required this.playlist,
    this.songs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, _) {
          // Get songs from the playlist
          final playlistSongs = songs ?? playlist.songIds
              .map((id) => musicProvider.songs.firstWhere(
                    (song) => song.id == id,
                    orElse: () => Song(
                      id: 'unknown',
                      title: 'Unknown Song',
                      artist: 'Unknown Artist',
                      albumArt: 'assets/images/album1.jpg',
                      assetPath: 'assets/audio/song1.mp3',
                      duration: 0,
                      album: 'Unknown Album',
                    ),
                  ))
              .toList();
          
          return CustomScrollView(
            slivers: [
              // App bar with playlist info
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.cardBackground,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    playlist.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Playlist cover image or default
                      playlist.coverImagePath != null
                          ? Image.asset(
                              playlist.coverImagePath!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.cardBackground,
                              child: Icon(
                                Icons.music_note,
                                size: 80,
                                color: AppColors.lightGrey,
                              ),
                            ),
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (playlist.id != 'liked_songs')
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditPlaylistDialog(context, playlist);
                      },
                    ),
                ],
              ),
              
              // Playlist description
              if (playlist.description != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      playlist.description!,
                      style: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              
              // Play all button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    onPressed: playlistSongs.isEmpty
                        ? null
                        : () {
                            // Play all songs in the playlist
                            if (playlistSongs.isNotEmpty) {
                              // Get the song IDs in the playlist
                              final songIds = playlistSongs.map((s) => s.id).toList();
                              
                              // Set the queue to the playlist songs
                              Provider.of<QueueProvider>(context, listen: false)
                                  .setQueue(songIds);
                              
                              // Play the first song
                              musicProvider.playSong(playlistSongs.first);
                            }
                          },
                  ),
                ),
              ),
              
              // Song count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    '${playlistSongs.length} ${playlistSongs.length == 1 ? 'song' : 'songs'}',
                    style: TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              // Songs list
              if (playlistSongs.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No songs in this playlist',
                      style: TextStyle(color: AppColors.lightGrey),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = playlistSongs[index];
                      return Dismissible(
                        // Don't allow dismissing in "Liked Songs" playlist
                        key: Key(song.id),
                        direction: playlist.id == 'liked_songs'
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          if (playlist.id != 'liked_songs') {
                            // Remove song from playlist
                            Provider.of<PlaylistProvider>(context, listen: false)
                                .removeSongFromPlaylist(playlist.id, song.id);
                          }
                        },
                        child: SongTile(song: song),
                      );
                    },
                    childCount: playlistSongs.length,
                  ),
                ),
              
              // Extra padding at the bottom for the mini player
              SliverToBoxAdapter(
                child: SizedBox(
                  height: musicProvider.currentSong != null ? 70 : 16,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showEditPlaylistDialog(BuildContext context, Playlist playlist) {
    final nameController = TextEditingController(text: playlist.name);
    final descriptionController = TextEditingController(text: playlist.description ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Edit Playlist',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: AppColors.lightGrey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: AppColors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: TextStyle(color: AppColors.lightGrey),
              ),
            ),
          ],
        ),
        actions: [
          // Delete playlist button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, playlist);
            },
            child: Text(
              'DELETE',
              style: TextStyle(color: Colors.red[300]),
            ),
          ),
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: AppColors.lightGrey),
            ),
          ),
          // Save button
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Provider.of<PlaylistProvider>(context, listen: false).renamePlaylist(
                  playlist.id,
                  nameController.text.trim(),
                  newDescription: descriptionController.text.trim().isNotEmpty
                      ? descriptionController.text.trim()
                      : null,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Delete Playlist',
          style: TextStyle(color: AppColors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"?',
          style: TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: AppColors.lightGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<PlaylistProvider>(context, listen: false)
                  .deletePlaylist(playlist.id);
              Navigator.pop(context);
              Navigator.pop(context); // Go back to library screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
