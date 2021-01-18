# NESBomberman
Traditional NES Bomberman Game in Turing

1 player gameplay
![1 player bomberman gameplay](https://i.imgur.com/S7MJBxc.png)

2 player gameplay
![2 player bomberman gameplay](https://i.imgur.com/HbkU64k.png)

Tutorial
![bomberman tutorial](https://i.imgur.com/TRajr0X.png)

Graphics:
solid block
item block (breakable block)
ladder (warps to the next level)
item pics (5): pow, bombs, speed, pierce, kick)
player pics (2)(12): (white/black)(3 each: front,back,left,right)
player death pics (2)(8): (white/black) (8 frames)
player 1 and 2 profiles (large icons on the sides of in-game banner)
enemy pics (2)(12): (balloon/chaser)(3 each: front,back,left,right)
enemy death pics (2): (balloon/chaser)

Classes and Main Functions/Procedures:
Enemy
chooses new rand direction at each intersection
will not backtrack on straightaways

Item
- Spawn Rate from every breakable block
Chance: 1,1,0.5,0.33,0.25,0.2,etc.
#Items: 0,1,2,3,4,5,etc.
Start with random powerups, # = level
Pierce and Kick are limited to 1 item slot

Grid
TEXT FILE STREAMING LEVELS from "LEVELS.TXT"
% MAP LEGEND:
% -3 = edges of explosion cross
% -2 = connectors of explosion cross
% -1 = center of explosion cross
% 0 = empty space
% 1 = permanent wall
% 2 = bomb
% 3 = breakable crates (with item)
% 4 = spawned enemies

Bomb
Chain Detonation
Traps player/enemy in unless they have the kick powerup

Player
Movement
Kicking
Place bombs
Collect powerups

Score
kill: +1000 * (combo ^ 2) 
combo is # of kills with single bomb
clear level: +10000
player death from enemy: -3000
player death from own bomb: -5000
restart: -5000 from score at the start of the level

Tutorial
teaches movement, bombs, enemies, items, score
