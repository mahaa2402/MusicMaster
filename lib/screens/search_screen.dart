import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_music_stream/providers/music_provider.dart';
import 'package:my_music_stream/widgets/song_tile.dart';
import 'package:my_music_stream/utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              style: TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Search songs, artists...',
                hintStyle: TextStyle(color: AppColors.lightGrey),
                prefixIcon: Icon(Icons.search, color: AppColors.lightGrey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.lightGrey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Search results or categories
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildSearchCategories()
                : _buildSearchResults(),
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
  
  Widget _buildSearchCategories() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildCategoryCard('Pop', Colors.pink),
        _buildCategoryCard('Rock', Colors.blue),
        _buildCategoryCard('Hip Hop', Colors.green),
        _buildCategoryCard('Jazz', Colors.orange),
        _buildCategoryCard('Classical', Colors.purple),
        _buildCategoryCard('Electronic', Colors.teal),
      ],
    );
  }
  
  Widget _buildCategoryCard(String category, Color color) {
    return GestureDetector(
      onTap: () {
        _searchController.text = category;
        setState(() {
          _searchQuery = category;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withOpacity(0.2),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, _) {
        final searchResults = musicProvider.searchSongs(_searchQuery);
        
        if (searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.lightGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$_searchQuery"',
                  style: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            return SongTile(song: searchResults[index]);
          },
        );
      },
    );
  }
}
