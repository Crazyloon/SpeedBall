# SpeedBall
SpeedBall for DotA 2: a WC3 Remake

Original Gameplay: https://www.youtube.com/watch?v=00_Uifu7X-8

=====================
I. UNITS:
=====================

1. Hero: Controled by players.
2. Shop Keeper: Sells items to players.
3. Speed Ball: Spawns at load, can be intereacted with to smash enemies and other speed balls (watch out!).

=====================
II. Abilities:
=====================

Force Smash: (Player ability [ALL PLAYERS]) - Melee - Used to hit balls at other players
----
1. Can only be used on the Speed Ball.
2. If used on ball, player walks up and launches the ball
3. Ball travels away from the player at high speed in the direction they hit the ball

Dodge: (Player ability [ALL PLAYERS]) - Utility - Used to move quickly in a specified direction (START WITH TELEPORT FOR EASE AND TESTING)
----
1. Short cooldown (about 5 seconds)
2. Same idea as force staff, but pushes the user to the chosen vector
3. Moves from A to B over 0.5 seconds

Force Blast: (Player ability [ALL PLAYERS]) - Projectile - Used as a ranged Kick
----
1. Longer cooldown (about 20 seconds)
2. Throw a bolt of light at the ball to "kick" it from a distance.

=====================
III. Items:
=====================

1. Healing Potion: Heals the user for 50% of max health.

2. Speed Potion: Makes consuming unit move at 500 move speed.

3. Invisibility Potion: Makes unit invisible for 10 seconds.

4. Shield: Decreases the damage taken when struck by a ball for the item owner/wearer. Reduces move speed

5. Power Booster: Increases the speed at which a ball moves after being struck by item owner.

6. Boots: Increase movespeed

=====================
IV. Mechanics:
=====================

Initilization: (When the map first loads)
----
1. Place Speedballs and make them physics objects
2. Place players in spawn points, count down to game start

The Speed Ball: - Handled by a momentum collider, using BMD Physics Library
----
1. When hitting a player: Transfer damage to player based on speed, ricochet out with less power
2. When hitting a wall: Speed is reduced slightly, ball reflects at same angle it collides
3. When hitting a Speed Ball: Speed is increased slightly, balls reflect at collision angle and trasfer ownership
4. When Blasted by a player: Player gains ownership of the ball and anyone it hits is damaged by that player

Display:
----
1. Floating Damage text when players are struck
2. Lives left in lives mode.

The Arena:
----
1. The defined bounds which the ball cannot pass. Just raised terrain from hammer
	1a. Will possibly add aabox reflectors to walls to fix players being pushed up hill


=====================
V. Map:
=====================

Multiple Arenas (Future):
----
1. Use different tile sets
2. Some arenas contain obstacles / possibly hills
3. Arenas Voted as a possibility using 1 map with arenas throughout
