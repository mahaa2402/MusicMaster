# MyMusicStream

A complete Spotify-like music streaming Flutter mobile application with offline functionality.

## Features

- 🎵 Play, Pause, Next, Previous song controls using `just_audio`
- 🔐 Login & Register with local user data using `shared_preferences`
- ❤️ Like/unlike songs to add/remove from Favorites
- 🔍 Real-time Search by song or artist name
- 📱 Beautiful dark-themed UI similar to Spotify
- 🎶 Create and manage playlists
- 🔄 Shuffle and Repeat functionality
- 📊 Recently played tracking
- 📶 Network awareness with online/offline indication
- 🗂️ Library with Liked Songs, Recently Played, and custom Playlists
- 🔄 Queue management (add, reorder, remove songs)

## Project Structure

The application follows a clean, modular architecture:

- `models/`: Data models like Song, Playlist, User
- `providers/`: State management using Provider pattern
- `screens/`: UI screens for different app sections
- `widgets/`: Reusable UI components
- `utils/`: Helper functions and constants

## Setup Instructions

### Prerequisites

- Flutter SDK (2.17.0 or higher)
- Android Studio or VS Code with Flutter extensions
- An Android device or emulator

### Installation

1. Clone the repository:
   