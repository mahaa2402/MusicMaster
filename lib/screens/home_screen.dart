import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_music_stream/providers/auth_provider.dart';
import 'package:my_music_stream/providers/music_provider.dart';
import 'package:my_music_stream/providers/connectivity_provider.dart';
import 'package:my_music_stream/models/song.dart';
import 'package:my_music_stream/widgets/song_tile.dart';
import 'package:my_music_stream/widgets/custom_bottom_navigation.dart';
import 'package:my_music_stream/widgets/mini_player.dart';
import 'package:my_music_stream/widgets/connectivity_banner.dart';
import 'package:my_music_stream/screens/search_screen.dart';
import 'package:my_music_stream/screens/library_screen.dart';
import 'package:my_music_stream/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    // Initialize the screens
    _screens.add(_HomeTab()); // The actual home tab is a separate private widget
    _screens.add(const SearchScreen());
    _screens.add(const LibraryScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Current Screen
          _screens[_selectedIndex],
          
          // Connectivity Banner (if offline)
          Consumer<ConnectivityProvider>(
            builder: (context, connectivityProvider, _) {
              if (!connectivityProvider.isConnected) {
                return const ConnectivityBanner();
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Mini Player
          Positioned(
            left: 0,
            right: 0,
            bottom: 56, // Height of BottomNavigationBar
            child: Consumer<MusicProvider>(
              builder: (context, musicProvider, _) {
                if (musicProvider.currentSong == null) {
                  return const SizedBox.shrink();
                }
                return const MiniPlayer();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              'Home',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: AppColors.white,
                ),
                onPressed: () async {
                  // Show a simple logout dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.cardBackground,
                      title: Text('Logout', style: TextStyle(color: AppColors.white)),
                      content: Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(color: AppColors.lightGrey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel', style: TextStyle(color: AppColors.primary)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldLogout == true) {
                    await Provider.of<AuthProvider>(context, listen: false).logout();
                  }
                },
              ),
            ],
          ),
          
          // Welcome message
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Text(
                    'Welcome, ${authProvider.currentUser?.username ?? 'music lover'}!',
                    style: TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Recently played section
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final recentlyPlayedIds = authProvider.currentUser?.recentlyPlayedIds ?? [];
              
              if (recentlyPlayedIds.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Recently Played',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: Consumer<MusicProvider>(
                        builder: (context, musicProvider, _) {
                          final songs = recentlyPlayedIds
                              .map((id) => musicProvider.songs.firstWhere(
                                    (s) => s.id == id,
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
                          
                          if (songs.isEmpty) {
                            return Center(
                              child: Text(
                                'No recently played songs',
                                style: TextStyle(color: AppColors.lightGrey),
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _RecentlyPlayedCard(song: song),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // All songs section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'All Songs',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Songs list
          Consumer<MusicProvider>(
            builder: (context, musicProvider, _) {
              if (musicProvider.songs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                );
              }
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = musicProvider.songs[index];
                    return SongTile(song: song);
                  },
                  childCount: musicProvider.songs.length,
                ),
              );
            },
          ),
          
          // Extra padding at the bottom for the mini player
          SliverToBoxAdapter(
            child: Consumer<MusicProvider>(
              builder: (context, musicProvider, _) {
                // Add extra padding if song is playing to account for mini player
                return SizedBox(
                  height: musicProvider.currentSong != null ? 70 : 16,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyPlayedCard extends StatelessWidget {
  final Song song;
  
  const _RecentlyPlayedCard({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final musicProvider = Provider.of<MusicProvider>(context, listen: false);
        musicProvider.playSong(song);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album art
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(song.albumArt),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Song title
          SizedBox(
            width: 120,
            child: Text(
              song.title,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Artist name
          SizedBox(
            width: 120,
            child: Text(
              song.artist,
              style: TextStyle(
                color: AppColors.lightGrey,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
