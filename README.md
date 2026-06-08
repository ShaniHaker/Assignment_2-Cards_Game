# Assignment 2 – Card Game (iOS)
## Overview

This project is an iOS card game developed using Swift and Storyboard.
The project is a continuation of Assignment 1 and extends the original implementation with additional requirements, including portrait and landscape support, dark mode support, audio management, lifecycle handling, and game summary functionality.
The application allows the player to compete against the pc in a card comparison game. 
The project demonstrates the use of multiple view controllers, navigation, location services, timers, audio management, dark mode support, and responsive user interfaces for both portrait and landscape orientations.


## Main Features

### Location-Based Side Selection

When the application starts, the user's location is used to determine the game side:

* West Side
* East Side
The selected side is displayed throughout the game.

### Card Game Logic

* The game consists of 10 rounds.
* In each round, both the player and the computer receive a card.
* The card with the higher value wins the round.
* Scores are updated after each round.
* After all rounds are completed, a summary screen is displayed.

### Timer

* Each round includes a countdown timer of 3 seconds.
* The timer updates automatically during gameplay.
* Lifecycle management ensures proper timer behavior when navigating between screens.

### Portrait and Landscape Support

The application supports:
* Portrait orientation - vertical.
* Landscape orientation - horiazonal.
The UI automatically adapts to different screen sizes and orientations.

### Dark Mode Support

The application supports both:
* Light Mode
* Dark Mode
UI colors adapt automatically to the system appearance.

### Audio Support

The application includes several audio features to improve the user experience:
Background music plays during the game.
A card-flip sound effect is played whenever new cards are revealed during a round.
Background music is paused when the user leaves the game screen and resumes when returning to the game.
An ending sound is played when the game finishes and the winner is announced.
Audio playback is managed according to the application lifecycle to ensure a smooth user experience.


### Summary Screen

At the end of the game, a summary screen displays:
* Winner name
* Final score
* Option to return to the main menu


## Screenshots

### Main Screen

<img width="250" height="450" alt="E98B727D-7090-421D-827A-50BA24E0AD59" src="https://github.com/user-attachments/assets/3dcdcc73-3d6a-4534-be68-8e78c99124fd" />
<img width="250" height="450" alt="97CE9A6B-2C17-406D-9B8E-8595F465789A" src="https://github.com/user-attachments/assets/100a8675-45fa-42c4-b3d4-381ca20b2c71" />



### Name Selection Screen

<img width="250" height="450" alt="02622162-C36D-4D67-8732-5DA10985004D" src="https://github.com/user-attachments/assets/2bc77fea-4312-43b6-bb9a-38f353d9fda7" />


<img width="250" height="450" alt="09D4AA4A-4A5E-4850-9D11-27894D5B50B3" src="https://github.com/user-attachments/assets/2d2c1302-87af-4988-8b93-dd424821d55c" />


### Game Screen – Portrait
<img width="250" height="450" alt="848416C3-D99A-47CA-9E23-FED8194B2A92" src="https://github.com/user-attachments/assets/aae86745-a642-414a-a234-a769f2e0037a" />


### Game Screen – Landscape

<img width="450" height="250" alt="01DF1BE5-AC32-491E-AB8E-88E713078610" src="https://github.com/user-attachments/assets/9a9c6e70-b822-4ef4-9f88-13ba320c2926" />


### Summary Screen

<img width="250" height="450" alt="3415D1C2-DB52-450F-A279-20C1ACA9AC22" src="https://github.com/user-attachments/assets/039f448a-8035-4b16-a2dd-4df85f7a22e1" />


## Project Structure

### Main Components

* `ViewController`

  * Main screen and user interaction.

* `GameViewController`

  * Handles gameplay logic and UI updates.

* `SummaryViewController`

  * Displays final results and winner information.

* `GameAudioController`

  * Manages background music and sound effects.

* `LocationManager`

  * Determines East/West side based on user location.



## How to Run

1. Open the project in Xcode.
2. Select an iPhone simulator.
3. Build and run the application.
4. Allow location access when requested.
5. Enter a player name and start the game.



Shani Haker

Software Engineering – Afeka College
