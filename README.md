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



### Name Selection Screen

<img width="926" height="1812" alt="09D4AA4A-4A5E-4850-9D11-27894D5B50B3" src="https://github.com/user-attachments/assets/2d2c1302-87af-4988-8b93-dd424821d55c" />


### Game Screen – Portrait

[Insert Screenshot Here]

---

### Game Screen – Landscape

[Insert Screenshot Here]

---

### Dark Mode

[Insert Screenshot Here]

---

### Summary Screen

[Insert Screenshot Here]

---

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

---

## Technologies Used

* Swift
* UIKit
* Core Location
* Auto Layout
* AVFoundation

---

## How to Run

1. Open the project in Xcode.
2. Select an iPhone simulator.
3. Build and run the application.
4. Allow location access when requested.
5. Enter a player name and start the game.

---

## Assignment Requirements Implemented

✔ UIKit-based application

✔ Multiple View Controllers

✔ Navigation Controller

✔ Auto Layout Constraints

✔ Portrait and Landscape Support

✔ Dark Mode Support

✔ Location Services

✔ Timer Management

✔ Audio Playback

✔ Lifecycle Handling

✔ Game Logic Implementation

✔ Summary Screen

---

## Author

Shani Haker

Software Engineering – Afeka College
