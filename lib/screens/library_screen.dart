import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_music_stream/providers/auth_provider.dart';
import 'package:my_music_stream/providers/music_provider.dart';
import 'package:my_music_stream/providers/playlist_provider.dart';
import 'package:my_music_stream/screens/playlist_detail_screen.dart';
import 'package:my_music_stream/screens/create_playlist_screen.dart';
import 'package:my_music_stream/widgets/playlist_tile.dart';
import 'package:my_music_stream/utils/constants.dart';
import 'package:my_music_stream/models/song.dart';
import 'package:my_music_stream/models/playlist.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Library header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Library',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: AppColors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePlaylistScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.lightGrey,
            tabs: const [
              Tab(text: 'Playlists'),
              Tab(text: 'Liked Songs'),
              Tab(text: 'Recently Played'),
            ],
          ),
          
          // Tab view
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PlaylistsTab(),
                _LikedSongsTab(),
                _RecentlyPlayedTab(),
              ],
            ),
          ),
          
          // Extra padding for mini player
          Consumer<MusicProvider>(
            builder: (context, musicProvider, _) {
              return SizedBox(
                height: musicProvider.currentSong != null ? 70 : 0,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, _) {
        final playlists = playlistProvider.playlists
            .where((playlist) => playlist.id != 'liked_songs')
            .toList();
        
        if (playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.queue_music,
                  size: 64,
                  color: AppColors.lightGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No playlists yet',
                  style: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePlaylistScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Create a playlist'),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return PlaylistTile(
              playlist: playlist,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaylistDetailScreen(playlist: playlist),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LikedSongsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, MusicProvider>(
      builder: (context, authProvider, musicProvider, _) {
        final likedSongIds = authProvider.currentUser?.likedSongIds ?? [];
        
        if (likedSongIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: AppColors.lightGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No liked songs yet',
                  style: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Like a song by tapping the heart icon',
                  style: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        
        final likedSongs = likedSongIds
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
        
        // Find the "Liked Songs" playlist
        final likedSongsPlaylist = Provider.of<PlaylistProvider>(context)
            .playlists
            .firstWhere(
              (p) => p.id == 'liked_songs',
              orElse: () => Playlist(
                id: 'liked_songs',
                name: 'Liked Songs',
                description: 'Your favorite songs',
                coverImagePath: 'assets/images/album1.jpg',
                songIds: [],
                createdAt: DateTime.now(),
              ),
            );
        
        return PlaylistDetailScreen(
          playlist: likedSongsPlaylist,
          songs: likedSongs,
        );
        
      },
    );
  }
}

class _RecentlyPlayedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, MusicProvider>(
      builder: (context, authProvider, musicProvider, _) {
        final recentlyPlayedIds = authProvider.currentUser?.recentlyPlayedIds ?? [];
        
        if (recentlyPlayedIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: AppColors.lightGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No recently played songs',
                  style: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Play some music to see your history',
                  style: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        
        final recentlyPlayedSongs = recentlyPlayedIds
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
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: recentlyPlayedSongs.length,
          itemBuilder: (context, index) {
            final song = recentlyPlayedSongs[index];
            
            return ListTile(
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
                style: TextStyle(color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                song.artist,
                style: TextStyle(color: AppColors.lightGrey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                musicProvider.playSong(song);
              },
            );
          },
        );
      },
    );
  }
}
