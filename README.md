# NESBomberman
Bomberman Game in Turing inspired by the original NES Bomberman (1983)

## 1 player gameplay
![1 player bomberman gameplay](https://i.imgur.com/S7MJBxc.png)

## 2 player gameplay
![2 player bomberman gameplay](https://i.imgur.com/HbkU64k.png)

## Tutorial
![bomberman tutorial](https://i.imgur.com/TRajr0X.png)
The tutorial teaches basic movement and bomb placement controls while introducing enemies, items, and the score system.

## Sprites Folder

- solid block
- breakable item block
- ladder (warps to the next level)
- item pics (5): pow, bombs, speed, pierce, kick)
- player pics (2)(12): (white/black) (3 each: front,back,left,right)
- player death pics (2)(8): (white/black) (8 frames)
- player 1 and 2 profiles (large icons on the sides of in-game banner)
- enemy pics (2)(12): (balloon/chaser)(3 each: front,back,left,right)
- enemy death pics (2): (balloon/chaser)

## Gameplay and Design

### Enemies
Chooses a random direction to move in at each intersection, will not backtrack on straightaways

### Items
- Dropped from breakable item blocks
- Breakeable item block icon in player banner indicates number of items picked up
- Spawn rate decreases with the number of items picked up
- Start the level with the same number of powerups as the level number
- Pierce and Kick are passive abilities that do no stack
- All other powerups stack

### Legend for level design from "LEVELS.TXT"
- -3 = edges of explosion cross
- -2 = connectors of explosion cross
- -1 = center of explosion cross
- 0 = empty space
- 1 = permanent wall
- 2 = bomb
- 3 = breakable item blocks
- 4 = spawned enemies

### Bombs
- Flame powerup increases blast length
- Bomb powerup increases number of bombs that can be placed
- Pierce powerup allows blast to pierce through breakable item blocks
- Bombs can trigger other bombs through chain detonation
- Bombs are immobile once placed, unless player has the Kick powerup

### Players
- 1 player controls: WASD + spacebar
- 2 player controls: WASD + '1' and arrow keys + '/'
- Kick powerup allows player to kick bombs in a straight path
- Boots powerup increases player movement speed

### Score Modifiers
- kill: +1000 * (combo ^ 2), combo is # of kills with single bomb
- clear level: +10000
- player death from enemy: -3000
- player death from own bomb: -5000
- restart: -5000 from score at the start of the level



