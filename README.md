# Almost Tennis
Source code for my action sports Playdate game, "Almost Tennis". Fight a gauntlet of 10 different enemies with three different classes, each with their own unique abilities. Become the Almost Tennis champion! You can find the game on [Itch IO](https://squidgod.itch.io/almost-tennis).

<img src="https://github.com/user-attachments/assets/38814a6e-d80d-428a-aef4-ceb2878b56e9" width="400" height="240"/>
<img src="https://github.com/user-attachments/assets/7d29eccc-5a9f-4eb1-a14e-4fbf563c17c4" width="400" height="240"/>
<img src="https://github.com/user-attachments/assets/5aae87e6-e08a-48e2-b63b-b2f052e1d2c5" width="400" height="240"/>
<img src="https://github.com/user-attachments/assets/e18dbc87-8347-44ac-8470-2998418d899a" width="400" height="240"/>

## Project Structure
- `libraries/`
  - `AnimatedSprite.lua` - By Whitebrim - animation state machine
  - `Fluid.lua` - By Dustin Mierau - simple fluid simulation
  - `SceneManager.lua` - Handles scene transitions
  - `Shaker.lua` - By Dustin Mierau - detects shake from accelerometer
  - `Signal.lua` - By Dustin Mierau - implements the observer pattern
  - `Utilities.lua` - Some simple helper functions
- `scripts/`
  - `game/`
    - `enemies/`
      - `enemy.lua` - Draws enemy and handles AI
      - `enemyList.lua` - Data list of enemies and properties
    - `healthbar/`
      - `animatedHeart.lua` - Draws animated heart on the side
      - `healthbar.lua` - Draws the list of animatedHearts on the side
      - `hurtBurst.lua` - Draws animation when losing a point
    - `player/`
      - `characterStats.lua` - Data list of different classes and their properties
      - `hitbox.lua` - Generic hitbox class used by player and enemy to hit the ball
      - `player.lua` - Player character controller
      - `powerBar.lua` - Handles power ability and draws power bar on the side 
      - `racquet.lua` - Handles drawing the tennis racquet
    - `ball.lua` - Handles ball collision and physics
    - `gameEndScene.lua` - Scene that shows up when the game is won
    - `gameScene.lua` - Manages all game elements
    - `scoreBurst.lua` - Handles animation when point is scored
    - `wall.lua` - Generic collision box class used to create court bounds
  - `title/` - Code for the title
    - `titleScene.lua` - UI for the title screen
- `main.lua` - Entry point for the game

## License
All code is licensed under the terms of the MIT license except for `Fluid.lua`, `Shaker.lua`, and `Signal.lua` by Dustin Mierau.
