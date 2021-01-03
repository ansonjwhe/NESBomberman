%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programmer(s): Anson He
% Program Name : Bomberman Dungeon Crawler
% Description  : 7 Levels of PvE Bomberman with 1 player and 2 player coop modes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% GLOBAL VARIABLES & SETTINGS %%%%%
View.Set ("offscreenonly, graphics:750;650")
RGB.SetColor (255, 0.125, 0.376, 0)
var score : int := 0
var tutorial : int := 1
var user_input : array char of boolean
var Delay : int := 20
var grid : array 1 .. 11 of array 1 .. 15 of int
var bugfix : string := ""
var playerW : int := 36
var playerH : int := 42
var enemyW : int := 40
var enemyH : int := 40

var solidblock : int := Pic.FileNew ("Pics/solidblock.bmp")
solidblock := Pic.Scale (solidblock, 50, 50)
var itemblock : int := Pic.FileNew ("Pics/itemblock.bmp")
itemblock := Pic.Scale (itemblock, 50, 50)
var itemIcon : int := Pic.Scale (itemblock, 40, 40)
var ladder : int := Pic.FileNew ("Pics/ladder.bmp")

% 1 - blast length +1
% 2 - max bombs +1
% 3 - speed +1
% 4 - has pierce
% 5 - has kick
var tempitemPics : array 1 .. 5 of int
var itemPics : array 1 .. 5 of int
tempitemPics (1) := Pic.FileNew ("Pics/itemfire.bmp")
tempitemPics (2) := Pic.FileNew ("Pics/itembombup.bmp")
tempitemPics (3) := Pic.FileNew ("Pics/itemskate.bmp")
tempitemPics (4) := Pic.FileNew ("Pics/itempierce.bmp")
tempitemPics (5) := Pic.FileNew ("Pics/itemkick.bmp")
for i : 1 .. upper (itemPics)
    itemPics (i) := Pic.Scale (tempitemPics (i), 40, 40)
    Pic.Free (tempitemPics (i))
end for
var halfitemW : int := round (Pic.Width (itemPics (1)) / 2)
var halfitemH : int := round (Pic.Height (itemPics (1)) / 2)

% load player pics
var tempplayerPics : int
var playerPics : array 1 .. 2 of array 1 .. 12 of int
for playerNum : 1 .. 2
    for i : 1 .. 12
	if (i - 1) div 3 = 0 then
	    tempplayerPics := Pic.FileNew ("Pics/player" + intstr (playerNum) + "front" + intstr (i) + ".bmp")
	    playerPics (playerNum) (i) := Pic.Scale (tempplayerPics, playerW, playerH)
	elsif (i - 1) div 3 = 1 then
	    tempplayerPics := Pic.FileNew ("Pics/player" + intstr (playerNum) + "back" + intstr (i - 3) + ".bmp")
	    playerPics (playerNum) (i) := Pic.Scale (tempplayerPics, playerW, playerH)
	elsif (i - 1) div 3 = 2 then
	    tempplayerPics := Pic.FileNew ("Pics/player" + intstr (playerNum) + "side" + intstr (i - 6) + ".bmp")
	    playerPics (playerNum) (i) := Pic.Scale (tempplayerPics, playerW, playerH)
	elsif (i - 1) div 3 = 3 then
	    tempplayerPics := Pic.FileNew ("Pics/player" + intstr (playerNum) + "side" + intstr (i - 9) + ".bmp")
	    playerPics (playerNum) (i) := Pic.Scale (tempplayerPics, -playerW, playerH)
	end if
	Pic.Free (tempplayerPics)
    end for
end for

% load player death pics
var tempplayerDeathPics : int
var playerDeathPics : array 1 .. 2 of array 1 .. 8 of int
for playerNum : 1 .. 2
    for i : 1 .. 8
	tempplayerDeathPics := Pic.FileNew ("Pics/player" + intstr (playerNum) + "death" + intstr (i) + ".bmp")
	playerDeathPics (playerNum) (i) := Pic.Scale (tempplayerDeathPics, playerW, playerH)
	Pic.Free (tempplayerDeathPics)
    end for
end for

% load player profiles
var player1Profile : int := Pic.FileNew ("Pics/player1profile.bmp")
player1Profile := Pic.Scale (player1Profile, 100, 100)
var player2Profile : int := Pic.FileNew ("Pics/player2profile.bmp")
player2Profile := Pic.Scale (player2Profile, 100, 100)

% load enemy pics
var tempenemyPics : int
var enemyPics : array 1 .. 12 of int
for i : 1 .. 12
    if i = 1 or i = 2 then
	tempenemyPics := Pic.FileNew ("Pics/enemyfront" + intstr (i) + ".bmp")
	enemyPics (i) := Pic.Scale (tempenemyPics, enemyW, enemyH)
    elsif i = 3 then
	tempenemyPics := Pic.FileNew ("Pics/enemyfront" + intstr (2) + ".bmp")
	enemyPics (i) := Pic.Scale (tempenemyPics, -enemyW, enemyH)
    elsif i = 4 or i = 5 then
	tempenemyPics := Pic.FileNew ("Pics/enemyback" + intstr (i - 3) + ".bmp")
	enemyPics (i) := Pic.Scale (tempenemyPics, enemyW, enemyH)
    elsif i = 6 then
	tempenemyPics := Pic.FileNew ("Pics/enemyback" + intstr (2) + ".bmp")
	enemyPics (i) := Pic.Scale (tempenemyPics, -enemyW, enemyH)
    elsif (i - 1) div 3 = 2 then
	tempenemyPics := Pic.FileNew ("Pics/enemyside" + intstr (i - 6) + ".bmp")
	enemyPics (i) := Pic.Scale (tempenemyPics, -enemyW, enemyH)
    elsif (i - 1) div 3 = 3 then
	tempenemyPics := Pic.FileNew ("Pics/enemyside" + intstr (i - 9) + ".bmp")
	enemyPics (i) := Pic.Scale (tempenemyPics, enemyW, enemyH)
    end if
    Pic.Free (tempenemyPics)
end for

% load enemy death pics
var enemyDeathPics : int := Pic.FileNew ("Pics/enemydeath.bmp")
enemyDeathPics := Pic.Scale (enemyDeathPics, enemyW, enemyH)

%%%% GLOBAL FUNCTIONS AND PROCEDURES %%%%%
% position functions
% converts y to row, x to col, col to x, row to y, centers x in the col, centers y in the row
fcn getRow (y : int) : int
    result 11 - (y div 50)
end getRow

fcn getCol (x : int) : int
    result (x div 50) + 1
end getCol

fcn getX (col : int) : int
    result col * 50 - 25
end getX

fcn getY (row : int) : int
    result 575 - row * 50
end getY

fcn centerX (x : int) : int
    result getX (getCol (x))
end centerX

fcn centerY (y : int) : int
    result getY (getRow (y))
end centerY

% checks if a given row or col is at the top, bottom, left, or right
fcn atTop (row : int) : boolean
    if row <= 1 then
	result true
    else
	result false
    end if
end atTop

fcn atBottom (row : int) : boolean
    if row >= 11 then
	result true
    else
	result false
    end if
end atBottom

fcn atRight (col : int) : boolean
    if col >= 15 then
	result true
    else
	result false
    end if
end atRight

fcn atLeft (col : int) : boolean
    if col <= 1 then
	result true
    else
	result false
    end if
end atLeft

% checks if the cell in the direction(d) of the given position(r)(c) is open
% true as long as not at border and grid value is 0 or less
fcn dOpen (d, r, c : int) : boolean
    if d = 1 then
	if atTop (r) then
	    result false
	elsif grid (r - 1) (c) > 0 then
	    result false
	end if
    elsif d = 2 then
	if atRight (c) then
	    result false
	elsif grid (r) (c + 1) > 0 then
	    result false
	end if
    elsif d = 3 then
	if atBottom (r) then
	    result false
	elsif grid (r + 1) (c) > 0 then
	    result false
	end if
    elsif d = 4 then
	if atLeft (c) then
	    result false
	elsif grid (r) (c - 1) > 0 then
	    result false
	end if
    end if
    result true
end dOpen

% generates a frame (1, 2, or 3) depending on x and y position
% used for animating players/enemies/bombs
fcn getFrame (pos : int) : int
    var frame : int := pos mod 100 div 25
    if frame = 0 or frame = 2 then
	result 1
    elsif frame = 1 then
	result 2
    elsif frame = 3 then
	result 3
    end if
end getFrame

% writes text by aligning the text to a fraction of 1 in decimal form instead of using the x-value
% ex. 0.5 aligns to the center, and 0.33 aligns to 1/3 of the screen from the left
proc alignText (text : string, alignment : real, y, font, c : int)
    Font.Draw (text,
	round (alignment * (maxx - Font.Width (text, font))), y,
	font, c)
end alignText

% distance formula
fcn distance (x1, y1, x2, y2 : int) : real
    result sqrt ((y2 - y1) ** 2 + (x2 - x1) ** 2)
end distance

%%%%% ENEMY CLASS %%%%%
% generated and stored in a flexible array
% can move based on random movement, and "kills" the player on contact
% can be trapped in between bombs and walls, and dies upon contact with the blast zone
class Enemy
    import grid, getX, getY, getRow, getCol, centerX, centerY, dOpen, distance, bugfix
    export x, y, row, col, direction, enemyDeath, addTimer, setPos, setDirection, moveEnemy
    var x, y, row, col, newRow, newCol : int
    var direction : int := 3
    var move : boolean := true
    var numBlocked : int := 0
    var blocked : array 1 .. 4 of boolean := init (false, false, false, false)
    var newD : int := 0
    var speed : int := 3
    var enemyDeath : int := -1

    % procedures to adjust variables (position, type, timer, new target cell, direction
    proc setPos (r, c : int)
	row := r
	col := c
	x := getX (col)
	y := getY (row)
	newRow := row
	newCol := col
    end setPos

    proc addTimer (ms : int)
	enemyDeath += ms
    end addTimer

    proc setNewTarget ()
	if move = true and dOpen (direction, row, col) then
	    if direction = 1 then
		newRow := row - 1
		newCol := col
	    elsif direction = 2 then
		newRow := row
		newCol := col + 1
	    elsif direction = 3 then
		newRow := row + 1
		newCol := col
	    elsif direction = 4 then
		newRow := row
		newCol := col - 1
	    end if
	end if
    end setNewTarget

    proc setDirection (d : int)
	direction := d
    end setDirection

    % reverses direction
    proc backtrack ()
	if direction = 1 then
	    direction := 3
	elsif direction = 2 then
	    direction := 4
	elsif direction = 3 then
	    direction := 1
	elsif direction = 4 then
	    direction := 2
	end if
	setNewTarget
    end backtrack

    % randomly generates next target cell and adjusts direction accordingly
    proc randMove ()
	newRow := row
	newCol := col
	move := true
	for i : 1 .. 4
	    if ~dOpen (i, row, col) then
		blocked (i) := true
		numBlocked += 1
	    end if
	end for
	if numBlocked = 4 then
	    move := false
	elsif numBlocked = 3 then
	    for i : 1 .. 4
		if blocked (i) = false then
		    newD := i
		end if
	    end for
	elsif numBlocked = 2 then
	    if dOpen (direction, row, col) then
		newD := direction
	    else
		var tempDirections : array 1 .. 2 of int
		var tempPos : int := 1
		for i : 1 .. 4
		    if blocked (i) = false then
			tempDirections (tempPos) := i
			tempPos += 1
		    end if
		end for
		newD := tempDirections (Rand.Int (1, 2))
	    end if
	elsif numBlocked = 1 then
	    var tempDirections : array 1 .. 3 of int
	    var tempPos : int := 1
	    for i : 1 .. 4
		if blocked (i) = false then
		    tempDirections (tempPos) := i
		    tempPos += 1
		end if
	    end for
	    newD := tempDirections (Rand.Int (1, 3))
	else
	    newD := Rand.Int (1, 4)
	end if
	direction := newD
	setNewTarget
	for i : 1 .. 4
	    blocked (i) := false
	end for
	numBlocked := 0
    end randMove

    % moves enemy in chosen direction, backtracks if target cell is blocked
    proc moveEnemy ()
	if row = newRow and col = newCol then
	    if direction = 0 or (direction = 1 and y >= centerY (y)) or (direction = 2 and x >= centerX (x)) or (direction = 3 and y <= centerY (y)) or (direction = 4 and x <= centerX (x)) then
		x := centerX (x)
		y := centerY (y)
		randMove
	    end if
	end if
	if grid (newRow) (newCol) > 0 then
	    backtrack
	end if
	if direction = 1 then
	    y += speed
	elsif direction = 2 then
	    x += speed
	elsif direction = 3 then
	    y -= speed
	elsif direction = 4 then
	    x -= speed
	end if
	row := getRow (y)
	col := getCol (x)
    end moveEnemy
end Enemy
var enemyArr : flexible array 1 .. 0 of ^Enemy
var enemyPos : int := 1

% checks if the given row and col has an enemy
fcn hasEnemy (row, col : int) : boolean
    for i : 1 .. upper (enemyArr)
	if row = Enemy (enemyArr (i)).row and col = Enemy (enemyArr (i)).col then
	    result true
	end if
    end for
    result false
end hasEnemy

%%%%% ITEM CLASS %%%%%
% generated and stored in a flexible array in the grid class
% has position, type (5 types total), and live (if item can be collected or not)
class Item
    export row, col, Type, isLive, setPos, setType, setLive
    var row, col : int
    var Type : int
    var isLive : boolean := false

    proc setPos (r, c : int)
	row := r
	col := c
    end setPos

    proc setType (itemNum : int)
	Type := itemNum
    end setType

    proc setLive ()
	if isLive = false then
	    isLive := true
	end if
    end setLive
end Item

%%%%% GRID CLASS %%%%%
% contains enemy and item functions/procedures
% used to draw the map/layout of the level
% textfile streaming used to load levels from "Levels.txt"
class Grid
    import bugfix, itemblock, solidblock, ladder, getX, getY, grid, Enemy, enemyArr, enemyPos, Item, itemPics, halfitemW, halfitemH
    export ladderRow, ladderCol, setGrid, setLadder, clearLadder, drawGrid, itemPos, itemRate, addRate, setRate, clearItems, hasItem, spawnItem, updateItems
    var ladderRow, ladderCol : int := 0
    var itemRate : int := 0
    var itemArr : flexible array 1 .. 0 of ^Item
    var itemPos : int := 1

    % creates a new enemy
    proc createEnemy ()
	new enemyArr, enemyPos
	new Enemy, enemyArr (enemyPos)
	enemyPos += 1
    end createEnemy

    % loads the level from the text file into the 2D array grid
    var levelStream : int
    var str1 : string
    proc setGrid (level : int)
	open : levelStream, "Levels.txt", get
	loop
	    get : levelStream, str1 : *
	    if (level = 0 and str1 = "TUTORIAL") or (level = -1 and str1 = "TEST") then
		exit
	    end if
	    exit when str1 = "LEVEL " + intstr (level)
	end loop
	for i : 1 .. 11
	    get : levelStream, str1 : *
	    for j : 1 .. 15
		grid (i) (j) := strint (str1 (j))
		if strint (str1 (j)) = 4 then
		    grid (i) (j) := 0
		    createEnemy
		    Enemy (enemyArr (enemyPos - 1)).setPos (i, j)
		end if
	    end for
	end for
    end setGrid

    % increases the itemRate (less likely to spawn an item)
    proc addRate ()
	itemRate += 1
    end addRate

    % sets the itemRate to rate
    proc setRate (rate : int)
	itemRate := rate
    end setRate

    % calculates the chance of an item spawning
    % based on total # of items held by players
    fcn hasItem () : boolean
	var chance : int := Rand.Int (1, 100)
	if itemRate < 2 then
	    result true
	elsif chance <= (100 div itemRate) then
	    result true
	end if
	result false
    end hasItem

    % spawns one item at the given row and col
    proc spawnItem (row, col : int)
	new itemArr, itemPos
	new Item, itemArr (itemPos)
	Item (itemArr (itemPos)).setPos (row, col)
	Item (itemArr (itemPos)).setType (Rand.Int (1, upper (itemPics)))
	itemPos += 1
    end spawnItem

    % removes a single specific item
    proc removeItem (pos : int)
	if pos < upper (itemArr) then
	    for i : pos + 1 .. upper (itemArr)
		itemArr (i - 1) := itemArr (i)
	    end for
	end if
	new itemArr, upper (itemArr) - 1
	itemPos -= 1
    end removeItem

    % removes all items from the flexible array
    proc clearItems ()
	loop
	    exit when upper (itemArr) = 0
	    removeItem (1)
	end loop
    end clearItems

    % checks all items to see if they've been destroyed or collected
    fcn updateItems (row, col : int) : int
	if upper (itemArr) > 0 then
	    for i : 1 .. upper (itemArr)
		if grid (Item (itemArr (i)).row) (Item (itemArr (i)).col) < 0 and Item (itemArr (i)).isLive then
		    removeItem (i)
		    exit
		elsif Item (itemArr (i)).row = row and Item (itemArr (i)).col = col then
		    var newPowerUp : int := Item (itemArr (i)).Type
		    removeItem (i)
		    result newPowerUp
		end if
	    end for
	end if
	result 0
    end updateItems

    % spawns the ladder at the given row and col
    proc setLadder (r, c : int)
	ladderRow := r
	ladderCol := c
    end setLadder

    % resets the "next level"/ladder cel
    proc clearLadder ()
	ladderRow := 0
	ladderCol := 0
    end clearLadder

    % draws the map
    proc drawGrid ()
	Draw.FillBox (0, 0, maxx, 550, 255)
	for i : 1 .. 11
	    for j : 1 .. 15
		if grid (i) (j) = 1 then
		    Pic.Draw (solidblock, getX (j) - round (Pic.Width (solidblock) / 2), getY (i) - round (Pic.Height (solidblock) / 2), 2)
		elsif grid (i) (j) = 3 then
		    Pic.Draw (itemblock, getX (j) - round (Pic.Width (itemblock) / 2), getY (i) - round (Pic.Height (itemblock) / 2), 2)
		end if
	    end for
	end for
	if upper (itemArr) > 0 then
	    for i : 1 .. upper (itemArr)
		if grid (Item (itemArr (i)).row) (Item (itemArr (i)).col) = 0 or grid (Item (itemArr (i)).row) (Item (itemArr (i)).col) = 2 then
		    Item (itemArr (i)).setLive
		    Pic.Draw (itemPics (Item (itemArr (i)).Type), getX (Item (itemArr (i)).col) - halfitemW, getY (Item (itemArr (i)).row) - halfitemH, 2)
		end if
	    end for
	end if
	if ladderRow > 0 then
	    Pic.Draw (ladder, getX (ladderCol) - 25, getY (ladderRow) - 25, 2)
	end if
    end drawGrid
end Grid
var map : ^Grid
new Grid, map

%%%%% BOMB CLASS %%%%%
% generated and stored in flexible arrays which are altered in the player class
% has both bomb and blast animations
% can chain detonate
% powerups directly affect the bomb's performance
class Bomb
    import getCol, getRow, getX, getY, centerX, centerY, dOpen, grid, atLeft, atRight, atTop, atBottom, map, Grid, bugfix
    export x, y, row, col, bombID, setID, isLive, setTime, playerBlocked, newBomb, setNew, timer, direction, kicked, setPos, setDirection, setSpeed, setBombPow, setKicked, hasPierce, updateTime,
	updateAll, drawBomb, detonate, drawBlast, resetBlast, freePics

    % bomb stat variables
    var x, y, row, col, lastrow, lastcol : int
    var bombID : int
    var isLive : boolean := true
    var newBomb : boolean := true
    var timer : int := 1500
    var direction : int := 0
    var speed : int := 10
    var kicked : boolean := false
    var bombPow : int := 1
    var pierce : boolean := false
    var blocked : array 1 .. 4 of boolean := init (false, false, false, false)

    % bomb graphic variables
    var tempbombPics : array 1 .. 3 of int
    var bombStage : int := 1
    var bombPics : array 1 .. 3 of int
    for i : 1 .. 3
	tempbombPics (i) := Pic.FileNew ("Pics/bomb" + intstr (i) + ".bmp")
	bombPics (i) := Pic.Scale (tempbombPics (i), 40, 40)
	Pic.Free (tempbombPics (i))
    end for
    var halfbombW : int := round (Pic.Width (bombPics (1)) / 2)
    var halfbombH : int := round (Pic.Height (bombPics (1)) / 2)
    var tempblastPics : array 1 .. 4 of array 1 .. 7 of int
    var blastStage : int := 0
    var blastPics : array 1 .. 4 of array 1 .. 7 of int
    for i : 1 .. 4
	tempblastPics (i) (1) := Pic.FileNew ("Pics/blastcenter" + intstr (i) + ".bmp")
	tempblastPics (i) (2) := Pic.FileNew ("Pics/blastup" + intstr (i) + ".bmp")
	tempblastPics (i) (3) := Pic.FileNew ("Pics/blastright" + intstr (i) + ".bmp")
	tempblastPics (i) (4) := Pic.FileNew ("Pics/blastdown" + intstr (i) + ".bmp")
	tempblastPics (i) (5) := Pic.FileNew ("Pics/blastleft" + intstr (i) + ".bmp")
	tempblastPics (i) (6) := Pic.FileNew ("Pics/blasthorizontal" + intstr (i) + ".bmp")
	tempblastPics (i) (7) := Pic.FileNew ("Pics/blastvertical" + intstr (i) + ".bmp")
    end for
    for i : 1 .. 4
	for j : 1 .. 7
	    blastPics (i) (j) := Pic.Scale (tempblastPics (i) (j), 50, 50)
	    Pic.Free (tempblastPics (i) (j))
	end for
    end for
    var halfblastW : int := round (Pic.Width (blastPics (1) (1)) / 2) - 1
    var halfblastH : int := round (Pic.Height (blastPics (1) (1)) / 2) - 1

    % sets bomb variables
    proc setID (id : int)
	bombID := id
    end setID

    proc setPos (posx, posy : int)
	x := posx
	y := posy
	row := getRow (y)
	col := getCol (x)
	lastrow := getRow (y)
	lastcol := getCol (x)
    end setPos

    proc setDirection (d : int)
	if newBomb = false then
	    direction := d
	end if
    end setDirection

    proc setSpeed (s : int)
	speed := s * 2
    end setSpeed

    proc setBombPow (pow : int)
	bombPow := pow
    end setBombPow

    proc hasPierce ()
	pierce := true
    end hasPierce

    proc setKicked (kick : boolean)
	kicked := kick
    end setKicked

    proc setNew ()
	newBomb := false
    end setNew

    proc setTime (Time : int)
	timer -= Time
    end setTime

    % mid-travel, if the bomb is blocked by a player, it will stop
    proc playerBlocked (r, c : int)
	if isLive = true and newBomb = false and kicked = true then
	    if direction = 1 and row - 1 = r and col = c then
		kicked := false
		x := centerX (x)
		y := centerY (y)
	    end if
	    if direction = 2 and col + 1 = c and row = r then
		kicked := false
		x := centerX (x)
		y := centerY (y)
	    end if
	    if direction = 3 and row + 1 = r and col = c then
		kicked := false
		x := centerX (x)
		y := centerY (y)
	    end if
	    if direction = 4 and col - 1 = c and row = r then
		kicked := false
		x := centerX (x)
		y := centerY (y)
	    end if
	end if
    end playerBlocked

    % updates only the frame/picture used for animation
    proc updateTime ()
	if timer mod 200 div 50 = 0 or timer mod 200 div 50 = 2 then
	    bombStage := 2
	elsif timer mod 200 div 50 = 1 then
	    bombStage := 1
	elsif timer mod 200 div 50 = 3 then
	    bombStage := 3
	end if

	if timer <= 0 and isLive = true then
	    blastStage := 1
	elsif timer <= -150 then
	    blastStage := 4
	elsif timer <= -100 then
	    blastStage := 3
	elsif timer <= -50 then
	    blastStage := 2
	end if
    end updateTime

    % updates frame, checks if the bomb is blocked by a block, moves the bomb, and updates its position on the map/grid
    proc updateAll (ms : int)
	timer -= ms
	if timer mod 200 div 50 = 0 or timer mod 200 div 50 = 2 then
	    bombStage := 2
	elsif timer mod 200 div 50 = 1 then
	    bombStage := 1
	elsif timer mod 200 div 50 = 3 then
	    bombStage := 3
	end if

	if timer <= 0 and isLive = true then
	    blastStage := 1
	elsif timer <= -150 then
	    blastStage := 4
	elsif timer <= -100 then
	    blastStage := 3
	elsif timer <= -50 then
	    blastStage := 2
	end if
	if isLive = true and newBomb = false and kicked = true then
	    if dOpen (direction, row, col) = false then
		if direction = 1 and y > centerY (y) then
		    kicked := false
		    x := centerX (x)
		    y := centerY (y)
		end if
		if direction = 2 and x > centerX (x) then
		    kicked := false
		    x := centerX (x)
		    y := centerY (y)
		end if
		if direction = 3 and y < centerY (y) then
		    kicked := false
		    x := centerX (x)
		    y := centerY (y)
		end if
		if direction = 4 and x < centerX (x) then
		    kicked := false
		    x := centerX (x)
		    y := centerY (y)
		end if
	    end if
	    if kicked = true then
		if direction = 1 then
		    y += speed
		elsif direction = 2 then
		    x += speed
		elsif direction = 3 then
		    y -= speed
		elsif direction = 4 then
		    x -= speed
		end if
	    end if
	    col := getCol (x)
	    row := getRow (y)
	    if lastrow > row then
		grid (row + 1) (col) := 0
		lastrow := row
	    elsif lastcol < col then
		grid (row) (col - 1) := 0
		lastcol := col
	    elsif lastrow < row then
		grid (row - 1) (col) := 0
		lastrow := row
	    elsif lastcol > col then
		grid (row) (col + 1) := 0
		lastcol := col
	    end if
	    if grid (row) (col) = 0 then
		grid (row) (col) := 2
	    end if
	end if
    end updateAll

    % draws the bomb
    proc drawBomb ()
	Pic.Draw (bombPics (bombStage), x - halfbombW, y - halfbombH, 2)
    end drawBomb

    % detonates the bomb, meaning it is no longer live, and the blast animation will begin
    % also spawns items from item blocks and uses powerup variables to calculate blast
    proc detonate ()
	isLive := false
	x := centerX (x)
	y := centerY (y)
	row := getRow (y)
	col := getCol (x)
	for i : 0 .. bombPow
	    if ~ (atLeft (col)) and col - i >= 1 and grid (row) (col - 1) ~= 1 and grid (row) (col - i) > -2 and blocked (1) = false then
		if grid (row) (col - i) = 3 then
		    if Grid (map).hasItem () then
			Grid (map).spawnItem (row, col - i)
		    end if
		    if pierce = false then
			grid (row) (col - i) := -1
			blocked (1) := true
		    end if
		end if
		if grid (row) (col - i) ~= 1 then
		    if i = bombPow then
			grid (row) (col - i) := -1
		    else
			grid (row) (col - i) := -2
		    end if
		else
		    blocked (1) := true
		end if
	    end if
	    if ~ (atRight (col)) and col + i <= 15 and grid (row) (col + 1) ~= 1 and grid (row) (col + i) > -2 and blocked (2) = false then
		if grid (row) (col + i) = 3 then
		    if Grid (map).hasItem () then
			Grid (map).spawnItem (row, col + i)
		    end if
		    if pierce = false then
			grid (row) (col + i) := -1
			blocked (2) := true
		    end if
		end if
		if grid (row) (col + i) ~= 1 then
		    if i = bombPow then
			grid (row) (col + i) := -1
		    else
			grid (row) (col + i) := -2
		    end if
		else
		    blocked (2) := true
		end if
	    end if
	    if ~ (atTop (row)) and row - i >= 1 and grid (row - 1) (col) ~= 1 and grid (row - i) (col) > -2 and blocked (3) = false then
		if grid (row - i) (col) = 3 then
		    if Grid (map).hasItem () then
			Grid (map).spawnItem (row - i, col)
		    end if
		    if pierce = false then
			grid (row - i) (col) := -1
			blocked (3) := true
		    end if
		end if
		if grid (row - i) (col) ~= 1 then
		    if i = bombPow then
			grid (row - i) (col) := -1
		    else
			grid (row - i) (col) := -2
		    end if
		else
		    blocked (3) := true
		end if
	    end if
	    if ~ (atBottom (row)) and row + i <= 11 and grid (row + 1) (col) ~= 1 and grid (row + i) (col) > -2 and blocked (4) = false then
		if grid (row + i) (col) = 3 then
		    if Grid (map).hasItem () then
			Grid (map).spawnItem (row + i, col)
		    end if
		    if pierce = false then
			grid (row + i) (col) := -1
			blocked (4) := true
		    end if
		end if
		if grid (row + i) (col) ~= 1 then
		    if i = bombPow then
			grid (row + i) (col) := -1
		    else
			grid (row + i) (col) := -2
		    end if
		else
		    blocked (4) := true
		end if
	    end if
	    grid (row) (col) := -3
	end for
    end detonate

    % draws the blast of a detonated bomb
    proc drawBlast ()
	for i : 0 .. bombPow
	    if i = 0 then
		Pic.Draw (blastPics (blastStage) (1), x - halfblastW, y - halfblastH, 2)
	    else
		if ~ (atLeft (col)) and col - i >= 1 and grid (row) (col - 1) ~= 1 then
		    if grid (row) (col - i) = -1 then
			Pic.Draw (blastPics (blastStage) (5), getX (col - i) - halfblastW, getY (row) - halfblastH, 2)
		    elsif grid (row) (col - i) = -2 then
			Pic.Draw (blastPics (blastStage) (6), getX (col - i) - halfblastW, getY (row) - halfblastH, 2)
		    end if
		end if
		if ~ (atRight (col)) and col + i <= 15 and grid (row) (col + 1) ~= 1 then
		    if grid (row) (col + i) = -1 then
			Pic.Draw (blastPics (blastStage) (3), getX (col + i) - halfblastW, getY (row) - halfblastH, 2)
		    elsif grid (row) (col + i) = -2 then
			Pic.Draw (blastPics (blastStage) (6), getX (col + i) - halfblastW, getY (row) - halfblastH, 2)
		    end if
		end if
		if ~ (atTop (row)) and row - i >= 1 and grid (row - 1) (col) ~= 1 then
		    if grid (row - i) (col) = -1 then
			Pic.Draw (blastPics (blastStage) (2), getX (col) - halfblastW, getY (row - i) - halfblastH, 2)
		    elsif grid (row - i) (col) = -2 then
			Pic.Draw (blastPics (blastStage) (7), getX (col) - halfblastW, getY (row - i) - halfblastH, 2)
		    end if
		end if
		if ~ (atBottom (row)) and row + i <= 11 and grid (row + 1) (col) ~= 1 then
		    if grid (row + i) (col) = -1 then
			Pic.Draw (blastPics (blastStage) (4), getX (col) - halfblastW, getY (row + i) - halfblastH, 2)
		    elsif grid (row + i) (col) = -2 then
			Pic.Draw (blastPics (blastStage) (7), getX (col) - halfblastW, getY (row + i) - halfblastH, 2)
		    end if
		end if
	    end if
	end for
    end drawBlast

    % resets all the grid-values created from the detonation
    proc resetBlast ()
	isLive := false
	for i : 0 .. bombPow
	    if ~ (atLeft (col)) and col - i >= 1 then
		if grid (row) (col - i) < 0 then
		    if i = bombPow and grid (row) (col - i) = -2 then
			grid (row) (col - i) := -1
		    else
			grid (row) (col - i) := 0
		    end if
		end if
	    end if
	    if ~ (atRight (col)) and col + i <= 15 then
		if grid (row) (col + i) < 0 then
		    if i = bombPow and grid (row) (col + i) = -2 then
			grid (row) (col + i) := -1
		    else
			grid (row) (col + i) := 0
		    end if
		end if
	    end if
	    if ~ (atTop (row)) and row - i >= 1 then
		if grid (row - i) (col) < 0 then
		    if i = bombPow and grid (row - i) (col) = -2 then
			grid (row - i) (col) := -1
		    else
			grid (row - i) (col) := 0
		    end if
		end if
	    end if
	    if ~ (atBottom (row)) and row + i <= 11 then
		if grid (row + i) (col) < 0 then
		    if i = bombPow and grid (row + i) (col) = -2 then
			grid (row + i) (col) := -1
		    else
			grid (row + i) (col) := 0
		    end if
		end if
	    end if
	end for
    end resetBlast

    % frees up storage from all the pictures loaded
    % only used once the bomb is being removed
    proc freePics ()
	for i : 1 .. 3
	    Pic.Free (bombPics (i))
	end for
	for i : 1 .. 4
	    for j : 1 .. 7
		Pic.Free (blastPics (i) (j))
	    end for
	end for
    end freePics
end Bomb
var bombArr : flexible array 1 .. 0 of ^Bomb
var bombPos : int := 1

%%%%% PLAYER CLASS %%%%%
% gets userinput, can move, place bombs, collect items, and kick bombs
% created and stored in a flexible array to allow 2 player mode
class Player
    import score, Delay, user_input, grid, bugfix, atLeft, atRight, atTop, atBottom, getCol, getRow, centerX, centerY, dOpen, getFrame, Enemy, enemyArr, hasEnemy, Grid, map, Bomb, bombArr,
	bombPos, playerPics, playerDeathPics, playerW, playerH
    export Posx, Posy, row, col, numItems, bombPow, maxBombs, playerS, pierceNum, kickNum, addItem, setPos, setLive, deathTimer, minusBomb, resetBombsandItems, setPlayer, userAction, drawPlayer,
	updatePlayer, drawPlayerDeath

    % player stat variables
    var newItem : int
    var numItems : int := 0
    var iframes : int := 0
    var deathTimer : int := -1
    var bombPow : int := 1
    var numBombs : int := 0
    var maxBombs : int := 1
    var pierce : boolean := false
    var canKick : boolean := false

    % movement variables
    var Controls : array 1 .. 5 of char
    var playerNum : int
    var Posx, Posy : int
    var lastx, lasty : int
    var row : int := 11
    var col : int := 1
    var playerD : int := 3
    var playerS : int := 2

    % setting player variables
    fcn pierceNum () : string
	if pierce = true then
	    result "Y"
	else
	    result "N"
	end if
    end pierceNum

    fcn kickNum () : string
	if canKick = true then
	    result "Y"
	else
	    result "N"
	end if
    end kickNum

    proc setPos (posx, posy, direction : int)
	Posx := posx
	Posy := posy
	row := getRow (posy)
	col := getCol (posx)
	playerD := direction
    end setPos

    proc setLive ()
	deathTimer := -1
	iframes := 1000
    end setLive

    proc setPlayer (up, right, down, left, bomb : char, pNum, posx, posy, direction, pow, bombs, speed : int, penetrate, kick : boolean)
	Controls (1) := up
	Controls (2) := right
	Controls (3) := down
	Controls (4) := left
	Controls (5) := bomb
	playerNum := pNum
	Posx := posx
	Posy := posy
	row := getRow (posy)
	col := getCol (posx)
	playerD := direction
	playerS := speed
	bombPow := pow
	maxBombs := bombs
	numItems := 0
	pierce := penetrate
	canKick := kick
    end setPlayer

    % adds item ability depending on the item
    proc addItem (newItem : int)
	numItems += 1
	Grid (map).addRate ()
	if newItem = 1 then
	    bombPow += 1
	elsif newItem = 2 then
	    maxBombs += 1
	elsif newItem = 3 and playerS < 6 then
	    playerS += 1
	elsif newItem = 4 then
	    pierce := true
	elsif newItem = 5 then
	    canKick := true
	end if
    end addItem

    % generates a bomb
    proc createBomb ()
	new bombArr, bombPos
	new Bomb, bombArr (bombPos)
	Bomb (bombArr (bombPos)).setID (playerNum)
	Bomb (bombArr (bombPos)).setPos (centerX (Posx), centerY (Posy))
	Bomb (bombArr (bombPos)).setBombPow (bombPow)
	if pierce = true then
	    Bomb (bombArr (bombPos)).hasPierce
	end if
	grid (Bomb (bombArr (bombPos)).row) (Bomb (bombArr (bombPos)).col) := 2
	bombPos += 1
	numBombs += 1
    end createBomb

    % decreases the number of bombs the player currently has
    proc minusBomb ()
	numBombs -= 1
    end minusBomb

    % resets all bombs and items created and affected by this player
    proc resetBombsandItems ()
	if numBombs > 0 then
	    for i : 1 .. upper (bombArr)
		if i <= bombPos - 1 then
		    if Bomb (bombArr (i)).bombID = playerNum and numBombs > 0 then
			Bomb (bombArr (1)).resetBlast
			for j : i .. upper (bombArr) - 1
			    bombArr (j) := bombArr (j + 1)
			end for
			new bombArr, upper (bombArr) - 1
			bombPos -= 1
			numBombs -= 1
		    end if
		end if
	    end for
	end if
	numItems := 0
    end resetBombsandItems

    % draws the player
    proc drawPlayer ()
	if iframes = 0 or iframes mod 200 div 100 = 0 then
	    if playerD = 3 then
		Pic.Draw (playerPics (playerNum) (getFrame (Posy)), Posx - round (playerW / 2), Posy - round (playerH / 2), 2)
	    elsif playerD = 1 then
		Pic.Draw (playerPics (playerNum) (getFrame (Posy) + 3), Posx - round (playerW / 2), Posy - round (playerH / 2), 2)
	    elsif playerD = 2 then
		Pic.Draw (playerPics (playerNum) (getFrame (Posx) + 6), Posx - round (playerW / 2), Posy - round (playerH / 2), 2)
	    elsif playerD = 4 then
		Pic.Draw (playerPics (playerNum) (getFrame (Posx) + 9), Posx - round (playerW / 2), Posy - round (playerH / 2), 2)
	    end if
	end if
    end drawPlayer

    % draws the death animation
    proc drawPlayerDeath (ms : int)
	if deathTimer < 400 and deathTimer >= 0 then
	    var frame : int := deathTimer div 50 + 1
	    Pic.Draw (playerDeathPics (playerNum) (frame), Posx - round (playerW / 2), Posy - round (playerH / 2), picMerge)
	    deathTimer += ms
	end if
    end drawPlayerDeath

    % gets user input
    % can move in 4 directions and drop bombs
    % can also kick bombs by walking into them
    % updates direction based on previous x and y coords
    proc userAction ()
	lastx := Posx
	lasty := Posy
	% placing a bomb
	if user_input (Controls (5)) and grid (row) (col) = 0 and numBombs < maxBombs then
	    createBomb
	end if
	
	% logic shown in up movement applies to all 3 other directions
	% moving up
	if user_input (Controls (1)) then
	    playerD := 1
	    if atTop (row) then % if top row, can only move until the border
		if Posy < 549 - round (playerH / 2) then
		    if Posy + round (playerS * (Delay / 10)) >= 549 - round (playerH / 2) then
			Posy := 549 - round (playerH / 2)
		    else
			Posy += round (playerS * (Delay / 10))
		    end if
		end if
	    else
		if Posy < centerY (Posy) + 25 - round (playerH / 2) then % if not at top of cell, can continue to move up
		    if Posy + playerS * round (Delay / 10) >= centerY (Posy) + 24 - round (playerH / 2) then
			Posy := centerY (Posy) + 25 - round (playerH / 2)
		    else
			Posy += round (playerS * (Delay / 10))
		    end if
		elsif grid (row - 1) (col) < 1 then  % if at top of the cell and above cell is empty, can move up
		    if Posx >= centerX (Posx) - 25 + round (playerW / 2) and Posx <= centerX (Posx) + 25 - round (playerW / 2) then
			Posy += round (playerS * (Delay / 10))
		    end if
		elsif grid (row - 1) (col) = 2 and canKick = true then %if at top of the cel and above cell is a bomb, can kick if player has kick powerup
		    for i : 1 .. upper (bombArr)
			if Bomb (bombArr (i)).row = row - 1 and Bomb (bombArr (i)).col = col then
			    if dOpen (playerD, row - 1, col) = true and hasEnemy (row - 2, col) = false then
				if Posx >= centerX (Posx) - 25 + round (playerW / 2) and Posx <= centerX (Posx) + 25 - round (playerW / 2) then
				    Posy += round (playerS * (Delay / 10))
				    Bomb (bombArr (i)).setKicked (true)
				    Bomb (bombArr (i)).setDirection (playerD)
				    Bomb (bombArr (i)).setSpeed (playerS)
				end if
			    end if
			end if
		    end for
		end if
	    end if
	end if

	% moving right
	if user_input (Controls (2)) then
	    playerD := 2
	    if atRight (col) then
		if Posx < maxx - round (playerW / 2) then
		    if Posx + round (playerS * (Delay / 10)) >= maxx - round (playerW / 2) then
			Posx := maxx - round (playerW / 2)
		    else
			Posx += round (playerS * (Delay / 10))
		    end if
		end if
	    else
		if Posx < centerX (Posx) + 25 - round (playerW / 2) then
		    if Posx + playerS * round (Delay / 10) >= centerX (Posx) + 24 - round (playerW / 2) then
			Posx := centerX (Posx) + 25 - round (playerW / 2)
		    else
			Posx += round (playerS * (Delay / 10))
		    end if
		elsif grid (row) (col + 1) < 1 then
		    if Posy >= centerY (Posy) - 25 + round (playerH / 2) and Posy <= centerY (Posy) + 25 - round (playerH / 2) then
			Posx += round (playerS * (Delay / 10))
		    end if
		elsif grid (row) (col + 1) = 2 and canKick = true then
		    for i : 1 .. upper (bombArr)
			if Bomb (bombArr (i)).row = row and Bomb (bombArr (i)).col = col + 1 then
			    if dOpen (playerD, row, col + 1) = true and hasEnemy (row, col + 2) = false then
				if Posy >= centerY (Posy) - 25 + round (playerH / 2) and Posy <= centerY (Posy) + 25 - round (playerH / 2) then
				    Posx += round (playerS * (Delay / 10))
				    Bomb (bombArr (i)).setKicked (true)
				    Bomb (bombArr (i)).setDirection (playerD)
				    Bomb (bombArr (i)).setSpeed (playerS)
				end if
			    end if
			end if
		    end for
		end if
	    end if
	end if

	% movement down
	if user_input (Controls (3)) then
	    playerD := 3
	    if atBottom (row) then
		if Posy > round (playerH / 2) then
		    if Posy - playerS * round (Delay / 10) <= round (playerH / 2) then
			Posy := round (playerH / 2) + 1
		    else
			Posy -= round (playerS * (Delay / 10))
		    end if
		end if
	    else
		if Posy > centerY (Posy) - 25 + round (playerH / 2) then
		    if Posy - playerS * round (Delay / 10) <= centerY (Posy) - 24 + round (playerH / 2) then
			Posy := centerY (Posy) - 25 + round (playerH / 2)
		    else
			Posy -= round (playerS * (Delay / 10))
		    end if
		elsif grid (row + 1) (col) < 1 then
		    if Posx >= centerX (Posx) - 25 + round (playerW / 2) and Posx <= centerX (Posx) + 25 - round (playerW / 2) then
			Posy -= round (playerS * (Delay / 10))
		    end if
		elsif grid (row + 1) (col) = 2 and canKick = true then
		    for i : 1 .. upper (bombArr)
			if Bomb (bombArr (i)).row = row + 1 and Bomb (bombArr (i)).col = col then
			    if dOpen (playerD, row + 1, col) = true and hasEnemy (row + 2, col) = false then
				if Posx >= centerX (Posx) - 25 + round (playerW / 2) and Posx <= centerX (Posx) + 25 - round (playerW / 2) then
				    Posy -= round (playerS * (Delay / 10))
				    Bomb (bombArr (i)).setKicked (true)
				    Bomb (bombArr (i)).setDirection (playerD)
				    Bomb (bombArr (i)).setSpeed (playerS)
				end if
			    end if
			end if
		    end for
		end if
	    end if
	end if

	% movement left
	if user_input (Controls (4)) then
	    playerD := 4
	    if atLeft (col) then
		if Posx > round (playerW / 2) then
		    if Posx - playerS * round (Delay / 10) <= round (playerW / 2) then
			Posx := round (playerW / 2)
		    else
			Posx -= round (playerS * (Delay / 10))
		    end if
		end if
	    else
		if Posx > centerX (Posx) - 25 + round (playerW / 2) then
		    if Posx - playerS * round (Delay / 10) <= centerX (Posx) - 24 + round (playerW / 2) then
			Posx := centerX (Posx) - 25 + round (playerW / 2)
		    else
			Posx -= round (playerS * (Delay / 10))
		    end if
		elsif grid (row) (col - 1) < 1 then
		    if Posy >= centerY (Posy) - 25 + round (playerH / 2) and Posy <= centerY (Posy) + 25 - round (playerH / 2) then
			Posx -= round (playerS * (Delay / 10))
		    end if
		elsif grid (row) (col - 1) = 2 and canKick = true then
		    for i : 1 .. upper (bombArr)
			if Bomb (bombArr (i)).row = row and Bomb (bombArr (i)).col = col - 1 then
			    if dOpen (playerD, row, col - 1) = true and hasEnemy (row, col - 2) = false then
				if Posy >= centerY (Posy) - 25 + round (playerH / 2) and Posy <= centerY (Posy) + 25 - round (playerH / 2) then
				    Posx -= round (playerS * (Delay / 10))
				    Bomb (bombArr (i)).setKicked (true)
				    Bomb (bombArr (i)).setDirection (playerD)
				    Bomb (bombArr (i)).setSpeed (playerS)
				end if
			    end if
			end if
		    end for
		end if
	    end if
	end if
	% auto corner cutting
	% checks if a direction has been manually moved in
	% if not and the player is close enough to the next cell
	% the player will be autocorrected to the correct cell
	if Posx = lastx and user_input (Controls (1)) and ~atTop (row) then
	    if grid (row - 1) (col) < 1 or (grid (row - 1) (col) = 2 and canKick = true) then
		if Posx < centerX (Posx) - 25 + round (playerW / 2) then
		    Posx += round (playerS * (Delay / 10))
		elsif Posx > centerX (Posx) + 25 - round (playerW / 2) then
		    Posx -= round (playerS * (Delay / 10))
		end if
	    end if
	elsif Posy = lasty and user_input (Controls (2)) and ~atRight (col) then
	    if grid (row) (col + 1) < 1 or (grid (row) (col + 1) = 2 and canKick = true) then
		if Posy < centerY (Posy) - 25 + round (playerH / 2) then
		    Posy += round (playerS * (Delay / 10))
		elsif Posy > centerY (Posy) + 25 - round (playerH / 2) then
		    Posy -= round (playerS * (Delay / 10))
		end if
	    end if
	elsif Posx = lastx and user_input (Controls (3)) and ~atBottom (row) then
	    if grid (row + 1) (col) < 1 or (grid (row + 1) (col) = 2 and canKick = true) then
		if Posx < centerX (Posx) - 25 + round (playerW / 2) then
		    Posx += round (playerS * (Delay / 10))
		elsif Posx > centerX (Posx) + 25 - round (playerW / 2) then
		    Posx -= round (playerS * (Delay / 10))
		end if
	    end if
	elsif Posy = lasty and user_input (Controls (4)) and ~atLeft (col) then
	    if grid (row) (col - 1) < 1 or (grid (row) (col - 1) = 2 and canKick = true) then
		if Posy < centerY (Posy) - 25 + round (playerH / 2) then
		    Posy += round (playerS * (Delay / 10))
		elsif Posy > centerY (Posy) + 25 - round (playerH / 2) then
		    Posy -= round (playerS * (Delay / 10))
		end if
	    end if
	end if
	row := getRow (Posy)
	col := getCol (Posx)
	if lasty < Posy then
	    playerD := 1
	elsif lastx < Posx then
	    playerD := 2
	elsif lasty > Posy then
	    playerD := 3
	elsif lastx > Posx then
	    playerD := 4
	end if
    end userAction

    % updates bombs, death timers, and powerups
    proc updatePlayer (ms : int)
	if upper (bombArr) > 0 then
	    for i : 1 .. upper (bombArr)
		if Bomb (bombArr (i)).bombID = playerNum then
		    if Bomb (bombArr (i)).newBomb and (Bomb (bombArr (i)).row ~= row or Bomb (bombArr (i)).col ~= col) then
			Bomb (bombArr (i)).setNew
		    end if
		    Bomb (bombArr (i)).updateAll (ms)
		end if
		Bomb (bombArr (i)).playerBlocked (row, col)
	    end for
	end if
	if deathTimer < 0 then
	    if iframes > 0 then
		iframes -= ms
	    elsif iframes = 0 then
		if grid (row) (col) < 0 then
		    deathTimer := 0
		    score -= 5000
		else
		    if hasEnemy (row, col) then
			deathTimer := 0
			score -= 3000
		    end if
		end if
	    end if
	end if

	newItem := Grid (map).updateItems (row, col)
	if newItem > 0 then
	    addItem (newItem)
	end if
    end updatePlayer
end Player
var players : flexible array 1 .. 0 of ^Player
var totalPlayers : int := 1

%%%%% GAMEPLAY PROCEDURES %%%%%
% exit if players at ladder
fcn checkLadder () : boolean
    for i : 1 .. totalPlayers
	if Player (players (i)).row = Grid (map).ladderRow and Player (players (i)).col = Grid (map).ladderCol then
	    score += 10000
	    result true
	end if
    end for
    result false
end checkLadder

% get player input and update player variables
proc getInput ()
    for i : 1 .. totalPlayers
	if Player (players (i)).deathTimer < 0 then
	    Input.KeyDown (user_input)
	    Player (players (i)).userAction
	end if
	Player (players (i)).updatePlayer (Delay)
    end for
end getInput

% removes an enemy from the enemy array
proc removeEnemy (pos : int)
    if pos < upper (enemyArr) then
	for i : pos .. upper (enemyArr) - 1
	    enemyArr (i) := enemyArr (i + 1)
	end for
    end if
    new enemyArr, upper (enemyArr) - 1
    enemyPos -= 1
end removeEnemy

% updates all enemies in the array
% enemies can move, die, generate score, or generate the ladder/next level cell
proc updateEnemy (ms : int)
    var combo : int := 0
    if upper (enemyArr) > 0 then
	for i : 1 .. upper (enemyArr)
	    if i <= upper (enemyArr) then
		if Enemy (enemyArr (i)).enemyDeath < 0 then
		    if grid (Enemy (enemyArr (i)).row) (Enemy (enemyArr (i)).col) < 0 then
			Enemy (enemyArr (i)).addTimer (1)
			combo += 1
		    else
			Enemy (enemyArr (i)).moveEnemy
		    end if
		else
		    Enemy (enemyArr (i)).addTimer (ms)
		    if Enemy (enemyArr (i)).enemyDeath >= 250 then
			if upper (enemyArr) = 1 then
			    if tutorial = 3 then
				grid (8) (15) := 0
			    else
				Grid (map).setLadder (Enemy (enemyArr (i)).row, Enemy (enemyArr (i)).col)
			    end if
			end if
			removeEnemy (i)
		    end if
		end if
	    end if
	end for
    end if
    score += (combo ** 2) * 1000
end updateEnemy

% removes all enemies from the enemy array
proc clearEnemies ()
    loop
	exit when upper (enemyArr) = 0
	removeEnemy (1)
    end loop
end clearEnemies

% removes a bomb
proc removeBomb ()
    Player (players (Bomb (bombArr (1)).bombID)).minusBomb
    Bomb (bombArr (1)).freePics
    for i : 2 .. upper (bombArr)
	bombArr (i - 1) := bombArr (i)
    end for
    new bombArr, upper (bombArr) - 1
    bombPos -= 1
end removeBomb

% updates all bombs
% checks if blocked by an enemy, detonates if enough time has passed, will chain detonate other bombs if in range
proc updateBombs (ms : int)
    if upper (bombArr) > 0 then
	for i : 1 .. upper (bombArr)
	    if upper (enemyArr) > 0 then
		for j : 1 .. upper (enemyArr)
		    Bomb (bombArr (i)).playerBlocked (Enemy (enemyArr (j)).row, Enemy (enemyArr (j)).col)
		end for
	    end if
	end for
    end if
    loop
	exit when upper (bombArr) = 0 or Bomb (bombArr (1)).timer > -200
	if Bomb (bombArr (1)).timer <= -200 then
	    Bomb (bombArr (1)).resetBlast
	    removeBomb
	end if
    end loop
    var chain : boolean := false
    loop
	for i : 1 .. upper (bombArr)
	    if Bomb (bombArr (i)).timer <= 0 and Bomb (bombArr (i)).isLive then
		Bomb (bombArr (i)).detonate
		chain := true
	    elsif (grid (Bomb (bombArr (i)).row) (Bomb (bombArr (i)).col) < 0 and Bomb (bombArr (i)).isLive) then
		Bomb (bombArr (i)).setTime (Bomb (bombArr (i)).timer)
	    end if
	    Bomb (bombArr (i)).updateTime
	end for
	exit when chain = false
	chain := false
    end loop
end updateBombs

% draws all bombs and enemies
proc drawBombsandEnemies ()
    for i : 1 .. upper (bombArr)
	if Bomb (bombArr (i)).isLive then
	    Bomb (bombArr (i)).drawBomb
	else
	    Bomb (bombArr (i)).drawBlast
	end if
    end for
    if upper (enemyArr) > 0 then
	for i : 1 .. upper (enemyArr)
	    if Enemy (enemyArr (i)).enemyDeath >= 0 then
		Pic.Draw (enemyDeathPics, Enemy (enemyArr (i)).x - round (enemyW / 2), Enemy (enemyArr (i)).y - round (enemyH / 2), 2)
	    else
		if Enemy (enemyArr (i)).direction = 3 then
		    Pic.Draw (enemyPics (getFrame (Enemy (enemyArr (i)).y)), Enemy (enemyArr (i)).x - round (enemyW / 2), Enemy (enemyArr (i)).y - round (enemyH / 2), 2)
		elsif Enemy (enemyArr (i)).direction = 1 then
		    Pic.Draw (enemyPics (getFrame (Enemy (enemyArr (i)).y) + 3), Enemy (enemyArr (i)).x - round (enemyW / 2), Enemy (enemyArr (i)).y - round (enemyH / 2), 2)
		elsif Enemy (enemyArr (i)).direction = 2 then
		    Pic.Draw (enemyPics (getFrame (Enemy (enemyArr (i)).x) + 6), Enemy (enemyArr (i)).x - round (enemyW / 2), Enemy (enemyArr (i)).y - round (enemyH / 2), 2)
		elsif Enemy (enemyArr (i)).direction = 4 then
		    Pic.Draw (enemyPics (getFrame (Enemy (enemyArr (i)).x) + 9), Enemy (enemyArr (i)).x - round (enemyW / 2), Enemy (enemyArr (i)).y - round (enemyH / 2), 2)
		end if
	    end if
	end for
    end if
end drawBombsandEnemies

% check for player death, respawns with iframes after player death animation
proc checkDeath (x, y : int)
    for i : 1 .. totalPlayers
	if Player (players (i)).deathTimer < 0 then
	    Player (players (i)).drawPlayer
	elsif Player (players (i)).deathTimer < 400 then
	    Player (players (i)).drawPlayerDeath (Delay)
	elsif Player (players (i)).deathTimer = 400 then
	    if i = 1 then
		Player (players (i)).setPos (x, y, 3)
	    elsif i = 2 then
		Player (players (i)).setPos (maxx - x, y, 3)
	    end if
	    Player (players (i)).setLive
	end if
    end for
end checkDeath

% reseting all variables after leaving a game
proc resetAll ()
    for i : 1 .. totalPlayers
	Player (players (i)).resetBombsandItems
    end for
    Grid (map).clearItems
    Grid (map).clearLadder
    Grid (map).setRate (0)
    clearEnemies
end resetAll

%%%%% USER INTERFACE VARIABLES, PROCEDURES & FUNCTIONS %%%%%
var title : int := Font.New ("Courier New:36:Bold")
var heading : int := Font.New ("Courier New:24:Bold")
var text : int := Font.New ("Courier New:16:Bold")
var screen : int := 0
var scoreStream : int
var editStream : int
var str1 : string
var arr1P : array 1 .. 2 of array 1 .. 5 of string
var arr2P : array 1 .. 2 of array 1 .. 5 of string
var scorePos : int := 1
var options : int := 5
var level : int
var first : int := 1
var last : int := 7
var cleared : boolean := false
var restarted : boolean := false

% Selection Arrow
var arrow : int := Pic.FileNew ("Pics/arrow.bmp")
arrow := Pic.Scale (arrow, 30, 30)

% Preloaded Title Screen
var logo : int := Pic.FileNew ("Pics/titlescreen.bmp")
logo := Pic.Scale (logo, 500, 300)
Draw.FillBox (0, 0, maxx, maxy, black)
Pic.Draw (logo, (maxx div 2) - round (Pic.Width (logo) / 2), 475 - round (Pic.Height (logo) / 2), 2)
alignText ("1 PLAYER", 0.5, 250, heading, 0)
alignText ("2 PLAYERS", 0.5, 200, heading, 0)
alignText ("TUTORIAL", 0.5, 150, heading, 0)     %preload
alignText ("HIGHSCORES", 0.5, 100, heading, 0)
alignText ("EXIT", 0.5, 50, heading, 0)
var titleScreen : int := Pic.New (0, 0, maxx, maxy)
cls

% Preloaded Highscores
Draw.FillBox (50, 50, maxx - 50, maxy - 50, black)
Draw.Box (50, 50, maxx - 50, maxy - 50, 30)
alignText ("1 PLAYER", 0.35, 430, heading, 30)
alignText ("2 PLAYER", 0.8, 430, heading, 30)
alignText ("1st", 0.1, 360, heading, 30)
alignText ("2nd", 0.1, 310, heading, 30)
alignText ("3rd", 0.1, 260, heading, 30)
alignText ("4th", 0.1, 210, heading, 30)
alignText ("5th", 0.1, 160, heading, 30)
alignText ("PRESS ESC TO CONTINUE", 0.5, 80, heading, 30)
var highscoreScreen : int := Pic.New (0, 0, maxx, maxy)
cls

% Preloaded 1 Player Banner
Draw.FillBox (0, 550, maxx, maxy, black)
Draw.Box (0, 550, maxx, maxy, 30)
Pic.Draw (player1Profile, 0, 550, 2)
% numItems, pierce, kick, pow, bomb, speed
Pic.Draw (itemIcon, 140, 605, 2)
Pic.Draw (itemPics (4), 240, 605, 2)
Pic.Draw (itemPics (5), 340, 605, 2)
Pic.Draw (itemPics (1), 140, 555, 2)
Pic.Draw (itemPics (2), 240, 555, 2)
Pic.Draw (itemPics (3), 340, 555, 2)
var banner1P : int := Pic.New (0, 0, maxx, maxy)
cls

% Preloaded 2 Player Banner
Draw.FillBox (0, 550, maxx, maxy, black)
Draw.Box (0, 550, maxx, maxy, 30)
alignText ("SCORE", 0.5, 615, heading, 30)
Pic.Draw (player1Profile, 0, 550, 2)
Pic.Draw (player2Profile, maxx - 100, 550, 2)
Pic.Draw (itemIcon, 105, 605, 2)
Pic.Draw (itemPics (4), 175, 605, 2)
Pic.Draw (itemPics (5), 245, 605, 2)
Pic.Draw (itemPics (1), 105, 555, 2)
Pic.Draw (itemPics (2), 175, 555, 2)
Pic.Draw (itemPics (3), 245, 555, 2)

Pic.Draw (itemIcon, 440, 605, 2)
Pic.Draw (itemPics (4), 510, 605, 2)
Pic.Draw (itemPics (5), 580, 605, 2)
Pic.Draw (itemPics (1), 440, 555, 2)
Pic.Draw (itemPics (2), 510, 555, 2)
Pic.Draw (itemPics (3), 580, 555, 2)
var banner2P : int := Pic.New (0, 0, maxx, maxy)
cls

% Preloaded Pause Screen
Draw.FillBox (225, 150, maxx - 225, maxy - 150, black)
Draw.Box (225, 150, maxx - 225, maxy - 150, 30)
alignText ("PAUSED", 0.5, 450, title, 30)
alignText ("RESUME", 0.5, 330, heading, 30)
alignText ("RESTART", 0.5, 280, heading, 30)
alignText ("MAIN MENU", 0.5, 230, heading, 30)
var pauseScreen : int := Pic.New (0, 0, maxx, maxy)
cls

% changes the user selection on main menu or pause screen
proc updateOption (pos, numOptions : int)
    if (options = 1 and pos > 0) or (options = numOptions and pos < 0) then
	options += pos
    elsif options > 1 and options < numOptions then
	options += pos
    end if
end updateOption

% uses text file streaming to load highscores into arrays
proc loadScores ()
    open : scoreStream, "Highscores.txt", get
    for i : 1 .. 5
	for j : 1 .. 2
	    get : scoreStream, str1
	    arr1P (j) (i) := str1
	end for
    end for
    get : scoreStream, str1 : *
    for i : 1 .. 5
	for j : 1 .. 2
	    get : scoreStream, str1
	    arr2P (j) (i) := str1
	end for
    end for
    close : scoreStream
end loadScores

% checks if score from recently finished game is a highscore or not
% if it is, the arrays will be adjusted by inserting the highscore in the correct position
fcn isHighscore () : boolean
    if screen = 1 then
	for i : 1 .. 5
	    if score > strint (arr1P (1) (i)) then
		for decreasing j : 5 .. i + 1
		    arr1P (1) (j) := arr1P (1) (j - 1)
		    arr1P (2) (j) := arr1P (2) (j - 1)
		end for
		arr1P (1) (i) := intstr (score)
		scorePos := i
		result true
	    end if
	end for
    elsif screen = 2 then
	for i : 1 .. 5
	    if score > strint (arr2P (1) (i)) then
		for decreasing j : 5 .. i + 1
		    arr2P (1) (j) := arr2P (1) (j - 1)
		    arr2P (2) (j) := arr2P (2) (j - 1)
		end for
		arr2P (1) (i) := intstr (score)
		scorePos := i
		result true
	    end if
	end for
    end if
    result false
end isHighscore

% displays the highscores for 1 and 2 players
proc highScore ()
    loadScores
    var blur : int := Pic.New (0, 0, maxx, maxy)
    blur := Pic.Blur (blur, 5)
    Pic.Draw (blur, 0, 0, 2)
    Pic.Draw (highscoreScreen, 0, 0, 2)
    alignText ("HIGHSCORES", 0.5, 520, title, 30)
    for i : 1 .. 5
	Draw.Text (arr1P (1) (i), 275 - (length (arr1P (1) (i)) - 1) * 19, 410 - i * 50, heading, 30)
	Draw.Text (arr1P (2) (i), 330, 410 - i * 50, heading, 30)
    end for
    for i : 1 .. 5
	Draw.Text (arr2P (1) (i), 545 - (length (arr2P (1) (i)) - 1) * 19, 410 - i * 50, heading, 30)
	Draw.Text (arr2P (2) (i), 600, 410 - i * 50, heading, 30)
    end for
    % 1P ~ 275 - (length - 1) * 19, 330
    % 2P ~ 545 - (length - 1) * 19, 600
    % Y: 430 - i*50
    View.Update
    loop
	Input.KeyDown (user_input)
	if user_input (KEY_ESC) then
	    loop
		Input.KeyDown (user_input)
		exit when ~user_input (KEY_ESC)
	    end loop
	    exit
	end if
    end loop
    Pic.Free (blur)
end highScore

% ending screen
% asks for user input for name if it is a highscore
% updates both the array and the textfile
% displays new leaderboard
% if not a highscore, it skips straight to the leaderboard
proc updateScores ()
    loadScores
    var blur : int := Pic.New (0, 0, maxx, maxy)
    blur := Pic.Blur (blur, 5)
    if isHighscore () then
	var name : string := ""
	var timer : int := 0
	var c : string (1)
	loop
	    var yourScore : string := "YOUR SCORE: " + intstr (score)
	    var inputName : string := "ENTER YOUR NAME (3): " + name
	    Pic.Draw (blur, 0, 0, 2)
	    Draw.FillBox (50, 150, maxx - 50, maxy - 150, black)
	    Draw.Box (50, 150, maxx - 50, maxy - 150, 30)
	    if timer div 200 mod 3 < 2 then
		alignText ("HIGHSCORE!", 0.5, 410, title, 30)
	    end if
	    alignText (yourScore, 0.5, 325, title, 30)
	    alignText (inputName, 0.5, 260, heading, 30)
	    alignText ("PRESS ENTER TO CONTINUE", 0.5, 200, heading, 30)
	    View.Update
	    if hasch then
		getch (c)
		if c = chr (8) and name ~= "" then
		    name := name (1 .. length (name) - 1)
		elsif length (name) < 3 then
		    for i : 65 .. 90
			if c = chr (i) then
			    name += c
			    name := Str.Upper (name)
			end if
		    end for
		    for i : 97 .. 122
			if c = chr (i) then
			    name += c
			    name := Str.Upper (name)
			end if
		    end for
		end if
	    end if
	    Input.KeyDown (user_input)
	    if user_input (KEY_ENTER) and length (name) = 3 then
		if screen = 1 then
		    arr1P (2) (scorePos) := name
		elsif screen = 2 then
		    arr2P (2) (scorePos) := name
		end if
		open : editStream, "Highscores.txt", put
		for i : 1 .. 5
		    put : scoreStream, arr1P (1) (i)
		    put : scoreStream, arr1P (2) (i)
		end for
		put : scoreStream, skip
		for i : 1 .. 5
		    put : scoreStream, arr2P (1) (i)
		    put : scoreStream, arr2P (2) (i)
		end for
		close : scoreStream
		loop
		    Input.KeyDown (user_input)
		    exit when ~user_input (KEY_ENTER)
		end loop
		exit
	    end if
	    timer += 10
	    delay (10)
	    cls
	end loop
    end if
    var yourScore : string := "YOUR SCORE: " + intstr (score)
    Pic.Draw (blur, 0, 0, 2)
    Pic.Draw (highscoreScreen, 0, 0, 2)
    alignText (yourScore, 0.5, 520, title, 30)
    for i : 1 .. 5
	Draw.Text (arr1P (1) (i), 275 - (length (arr1P (1) (i)) - 1) * 19, 410 - i * 50, heading, 30)
	Draw.Text (arr1P (2) (i), 330, 410 - i * 50, heading, 30)
    end for
    for i : 1 .. 5
	Draw.Text (arr2P (1) (i), 545 - (length (arr2P (1) (i)) - 1) * 19, 410 - i * 50, heading, 30)
	Draw.Text (arr2P (2) (i), 600, 410 - i * 50, heading, 30)
    end for
    View.Update
    loop
	Input.KeyDown (user_input)
	if user_input (KEY_ESC) then
	    loop
		Input.KeyDown (user_input)
		exit when ~user_input (KEY_ESC)
	    end loop
	    exit
	end if
    end loop
    Pic.Free (blur)
    cls
end updateScores

% user input for pause screen
fcn selectPaused () : int
    Input.KeyDown (user_input)
    if user_input (' ') then
	loop
	    Input.KeyDown (user_input)
	    exit when ~user_input (' ')
	end loop
	result options
    elsif user_input (KEY_UP_ARROW) then
	updateOption (1, 3)
	loop
	    Input.KeyDown (user_input)
	    exit when ~user_input (KEY_UP_ARROW)
	end loop
    elsif user_input (KEY_DOWN_ARROW) then
	updateOption (-1, 3)
	loop
	    Input.KeyDown (user_input)
	    exit when ~user_input (KEY_DOWN_ARROW)
	end loop
    end if
    result 0
end selectPaused

% pause screen
% has options: "resume, restart, main menu"
proc paused ()
    var next : int
    options := 3
    Input.KeyDown (user_input)
    if user_input (KEY_ESC) then
	loop
	    Input.KeyDown (user_input)
	    exit when ~user_input (KEY_ESC)
	end loop
	var blur : int := Pic.New (0, 0, maxx, maxy)
	blur := Pic.Blur (blur, 5)
	loop
	    Pic.Draw (blur, 0, 0, 2)
	    Pic.Draw (pauseScreen, 0, 0, 2)
	    Pic.Draw (arrow, 235, options * 50 + 175, 2)
	    View.Update
	    Input.KeyDown (user_input)
	    next := selectPaused ()
	    if next = 2 then
		restarted := true
	    elsif next = 1 then
		screen := 0
	    end if
	    exit when next > 0
	    cls
	end loop
	Pic.Free (blur)
    end if
end paused

% user input for main menu selection
fcn selectMain () : int
    var next : int := 0
    Input.KeyDown (user_input)
    if user_input (' ') then
	if options = 5 then
	    next := 1
	elsif options = 4 then
	    next := 2
	elsif options = 3 then
	    next := 3
	elsif options = 2 then
	    next := 4
	elsif options = 1 then
	    next := -1
	end if
	loop
	    Input.KeyDown (user_input)
	    exit when ~user_input (' ')
	end loop
    elsif user_input (KEY_UP_ARROW) then
	updateOption (1, 5)
	loop
	    Input.KeyDown (user_input)
	    exit when ~user_input (KEY_UP_ARROW)
	end loop
    elsif user_input (KEY_DOWN_ARROW) then
	updateOption (-1, 5)
	loop
	    Input.KeyDown (user_input)
	    exit when ~user_input (KEY_DOWN_ARROW)
	end loop
    end if
    result next
end selectMain

% main menu screen
proc mainMenu ()
    options := 5
    loop
	Pic.Draw (titleScreen, 0, 0, 2)
	Pic.Draw (arrow, 230, options * 50 - 5, 2)
	View.Update
	screen := selectMain ()
	exit when screen ~= 0
	cls
    end loop
end mainMenu

% CONTROLS: up, right, down, left, bomb --- PLAYER VARIABLES: posx, posy, direction, pow, bombs, speed, pierce, kick
% sets up variables for a new game depending on the number of players
% generates free powerups according to the level
% player starts with more powerups at higher levels
proc startGame ()
    totalPlayers := screen
    new players, totalPlayers
    for i : 1 .. totalPlayers
	new Player, players (i)
    end for
    if screen = 1 then
	Player (players (1)).setPlayer (KEY_UP_ARROW, KEY_RIGHT_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW, ' ', 1, 25, 25, 3, 1, 1, 3, false, false)
    elsif screen = 2 then
	Player (players (1)).setPlayer ('w', 'd', 's', 'a', '1', 1, 25, 25, 3, 1, 1, 3, false, false)
	Player (players (2)).setPlayer (KEY_UP_ARROW, KEY_RIGHT_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW, '/', 2, maxx - 25, 25, 3, 1, 1, 3, false, false)
    end if
    for i : 1 .. totalPlayers
	loop
	    exit when Player (players (i)).numItems >= level
	    var itemType : int := Rand.Int (1, 5)
	    if ~ ((Player (players (i)).pierceNum () = "Y" and itemType = 4) or (Player (players (i)).kickNum () = "Y" and itemType = 5) or (Player (players (i)).playerS >= 6 and itemType = 3))
		    then
		Player (players (i)).addItem (itemType)
	    end if
	end loop
    end for
    Grid (map).setGrid (level)
end startGame

% draws the in-game banner depending on the game mode (1P, 2P, tutorial)
proc drawStats ()
    if screen = 1 then
	Pic.Draw (banner1P, 0, 0, 2)
	var yourScore : string := "SCORE: " + intstr (score)
	Draw.Text (yourScore, 480, 590, heading, 30)
	Draw.Text (Player (players (1)).pierceNum (), 285, 615, heading, 30)
	Draw.Text (Player (players (1)).kickNum (), 385, 615, heading, 30)
	Draw.Text (intstr (Player (players (1)).numItems), 185, 615, heading, 30)
	Draw.Text (intstr (Player (players (1)).bombPow), 185, 565, heading, 30)
	Draw.Text (intstr (Player (players (1)).maxBombs), 285, 565, heading, 30)
	Draw.Text (intstr (Player (players (1)).playerS), 385, 565, heading, 30)
    elsif screen = 2 then
	Pic.Draw (banner2P, 0, 0, 2)
	alignText (intstr (score), 0.5, 575, heading, 30)
	Draw.Text (intstr (Player (players (1)).numItems), 148, 615, heading, 30)
	Draw.Text (Player (players (1)).pierceNum (), 218, 615, heading, 30)
	Draw.Text (Player (players (1)).kickNum (), 288, 615, heading, 30)
	Draw.Text (intstr (Player (players (1)).bombPow), 148, 565, heading, 30)
	Draw.Text (intstr (Player (players (1)).maxBombs), 218, 565, heading, 30)
	Draw.Text (intstr (Player (players (1)).playerS), 288, 565, heading, 30)
	Draw.Text (intstr (Player (players (2)).numItems), 483, 615, heading, 30)

	Draw.Text (Player (players (2)).pierceNum (), 553, 615, heading, 30)
	Draw.Text (Player (players (2)).kickNum (), 623, 615, heading, 30)
	Draw.Text (intstr (Player (players (2)).bombPow), 483, 565, heading, 30)
	Draw.Text (intstr (Player (players (2)).maxBombs), 553, 565, heading, 30)
	Draw.Text (intstr (Player (players (2)).playerS), 623, 565, heading, 30)
    elsif screen = 3 then
	Pic.Draw (banner1P, 0, 0, 2)
	Draw.Text ("TUTORIAL", 500, 590, heading, 30)
	Draw.Text (Player (players (1)).pierceNum (), 285, 615, heading, 30)
	Draw.Text (Player (players (1)).kickNum (), 385, 615, heading, 30)
	Draw.Text (intstr (Player (players (1)).numItems), 185, 615, heading, 30)
	Draw.Text (intstr (Player (players (1)).bombPow), 185, 565, heading, 30)
	Draw.Text (intstr (Player (players (1)).maxBombs), 285, 565, heading, 30)
	Draw.Text (intstr (Player (players (1)).playerS), 385, 565, heading, 30)
    end if
    %put "Bug: ", bugfix
end drawStats

% main gameplay procedure
% update grid, bombs, and enemies, then draw all graphics
proc runGame (x, y : int)
    cls
    cleared := checkLadder ()
    getInput
    updateEnemy (Delay)
    updateBombs (Delay)
    Grid (map).drawGrid
    drawBombsandEnemies
    checkDeath (x, y)
    drawStats
    delay (Delay)
end runGame

% plays through the tutorial (teaches movement, bombs, enemies, items, score)
proc playTutorial ()
    loop
	tutorial := 1
	Grid (map).setGrid (0)
	Player (players (1)).setPlayer (KEY_UP_ARROW, KEY_RIGHT_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW, ' ', 1, 25, 275, 3, 1, 1, 3, false, true)
	Grid (map).setRate (101)
	loop
	    if tutorial = 1 then
		runGame (25, 275)
		Draw.Box (100, 200, 150, 250, yellow)
		Draw.FillBox (0, 350, 300, 550, black)
		Draw.Box (0, 350, 300, 550, 30)
		alignText ("Movement", 0.15, 520, text, 30)
		Draw.Text ("1 Player: Arrow Keys", 20, 490, text, 30)
		Draw.Text ("2 Players:", 20, 450, text, 30)
		Draw.Text ("Player 1: WASD", 20, 420, text, 30)
		Draw.Text ("Player 2: Arrow Keys", 20, 390, text, 30)
		if Player (players (1)).row = 7 and Player (players (1)).col = 3 then
		    tutorial := 2
		end if
	    elsif tutorial = 2 then
		runGame (125, 225)
		Draw.Box (0, 0, 50, 50, yellow)
		Draw.FillBox (0, 350, 300, 550, black)
		Draw.Box (0, 350, 300, 550, 30)
		alignText ("Bombs", 0.17, 520, text, 30)
		Draw.Text ("1 Player: Space Bar", 20, 490, text, 30)
		Draw.Text ("2 Players:", 20, 450, text, 30)
		Draw.Text ("Player 1: '1'", 20, 420, text, 30)
		Draw.Text ("Player 2: '/'", 20, 390, text, 30)
		if Player (players (1)).row = 11 and Player (players (1)).col = 1 then
		    tutorial := 3
		end if
	    elsif tutorial = 3 then
		runGame (25, 25)
		Draw.FillBox (0, 350, 300, 550, black)
		Draw.Box (0, 350, 300, 550, 30)
		if grid (8) (15) = 0 then
		    Draw.Box (700, 150, 750, 200, yellow)
		end if
		alignText ("Enemies", 0.16, 520, text, 30)
		alignText ("*DANGER*", 0.15, 490, text, 30)
		Draw.Text ("Drifty the balloon:", 10, 450, text, 30)
		Draw.Text ("Wanders aimlessly", 10, 420, text, 30)
		Draw.Text ("Can't float past bombs", 10, 390, text, 30)
		if Player (players (1)).row = 8 and Player (players (1)).col = 15 then
		    tutorial := 4
		    Grid (map).setRate (-100)
		end if
	    elsif tutorial = 4 then
		runGame (725, 175)
		Draw.Box (300, 500, 350, 550, yellow)
		Draw.FillBox (0, 350, 300, 550, black)
		Draw.Box (0, 350, 300, 550, 30)
		alignText ("Items", 0.17, 520, text, 30)
		Draw.Text ("Brick: # of Held Items", 10, 485, text, 30)
		Draw.Text ("Spikes: Enables Pierce", 10, 460, text, 30)
		Draw.Text ("Kick: Enables Kick", 10, 435, text, 30)
		Draw.Text ("Flame: Blast Length +1", 10, 410, text, 30)
		Draw.Text ("Bomb: Max # Bombs +1", 10, 385, text, 30)
		Draw.Text ("Shoe: Speed +1", 10, 360, text, 30)
		if Player (players (1)).row = 1 and Player (players (1)).col = 7 then
		    tutorial := 5
		end if
	    elsif tutorial = 5 then
		runGame (325, 525)
		Draw.FillBox (0, 350, 300, 550, black)
		Draw.Box (0, 350, 300, 550, 30)
		alignText ("Score", 0.17, 520, text, 30)
		Draw.Text ("Kill: +1000 * combo", 10, 485, text, 30)
		Draw.Text ("Clear Level: +10000", 10, 460, text, 30)
		Draw.Text ("Death by Enemy: -3000", 10, 435, text, 30)
		Draw.Text ("Death by Bomb: -5000", 10, 410, text, 30)
		Draw.Text ("Restart: reset, -5000", 10, 385, text, 30)
		alignText ("END OF TUTORIAL", 0.1, 360, text, 30)
	    end if
	    View.Update
	    paused             % if esc pressed, pauses game
	    exit when restarted = true or screen = 0
	end loop
	resetAll
	restarted := false
	exit when screen = 0
    end loop
end playTutorial


%%%%% MAIN CODE %%%%%
loop
    % SCREENS:
    % -1 - close game
    % 0 - title screen
    % 1 - 1 player game
    % 2 - 2 player game
    % 3 - tutorial
    % 4 - highscores
    if screen = 0 then
	score := 0
	level := first
	mainMenu
    elsif screen = 1 or screen = 2 then
	cls
	var lastscore : int := score
	startGame
	% main game loop
	loop
	    runGame (25, 25)
	    View.Update
	    paused     % if esc pressed, pauses game
	    if restarted = true then
		score := lastscore - 5000
	    end if
	    exit when cleared = true or restarted = true or screen = 0
	end loop
	resetAll
	% if level was cleared, move onto next level
	if cleared = true then
	    % the last level will spawn the ending/winning screen instead of next level
	    if level = last then
		updateScores
		screen := 0
	    end if
	    level += 1
	    cleared := false
	end if
	restarted := false
    elsif screen = 3 then
	cls
	totalPlayers := 1
	new players, totalPlayers
	new Player, players (totalPlayers)
	playTutorial
    elsif screen = 4 then
	highScore
	screen := 0
    end if
    exit when screen = -1
end loop
cls
Draw.FillBox (0, 0, maxx, maxy, black)
alignText ("THANKS FOR PLAYING!", 0.5, maxy div 2 + 30, heading, 30)
alignText ("Created by: Anson He", 0.5, maxy div 2 - 30, heading, 30)
View.Update
