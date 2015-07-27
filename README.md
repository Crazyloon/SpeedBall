# SpeedBall
SpeedBall for DotA 2: a WC3 Remake

SpeedBall: A game port from WC3 -> DotA 2

Original Gameplay: https://www.youtube.com/watch?v=00_Uifu7X-8

=====================
I. UNITS:
=====================

1. Hero: Controled by players.
2. Shop Keeper: Sells items to players.
3. Speed Ball: Spawns at load, can be intereacted with to smash enemies and self (watch out!).

=====================
II. Abilities:
=====================

1. Force Smash: (Player ability [ALL PLAYERS]) - Melee - Used to hit balls at other players
	¤ Can only be used on the Speed Ball.
	¤ If used on ball, player walks up and launches the ball
	¤ Ball travels away from the player at high speed in the direction they hit the ball

2. Dodge: (Player ability [ALL PLAYERS]) - Utility - Used to move quickly in a specified direction 
   (START WITH TELEPORT FOR EASE AND TESTING)
	¤ Short cooldown (about 5 seconds)
	¤ Same idea as force staff, but pushes the user to the chosen vector
	¤ Moves from A to B over 0.5 seconds

3. Force Blast: (Player ability [ALL PLAYERS]) - Projectile - Used as a ranged Kick
	¤ Longer cooldown (about 20 seconds)
	¤ Throw a bolt of light at the ball to "kick" it from a distance.

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

1. Initilization: (When the map first loads)
	¤ Place Speedballs and make them physics objects
	¤ Place players in spawn points, count down to game start

2. The Speed Ball: - Handled by a momentum collider, using BMD Physics Library
	¤ When hitting a player: Transfer damage to player based on speed, ricochet out with less power
	¤ When hitting a wall: Speed is reduced slightly, ball reflects at same angle it collides
	¤ When hitting a Speed Ball: Speed is increased slightly, balls reflect at collision angle and trasfer ownership
  ¤ When Blasted by a player: Player gains ownership of the ball and anyone it hits is damaged by that player

3. Display:
	¤ Floating Damage text when players are struck
	¤ Lives left in lives mode.

4. The Arena:
	¤ The defined bounds which the ball cannot pass. Just raised terrain from hammer
      - Will possibly add aabox reflectors


=====================
V. Map:
=====================

1. Multiple Arenas (Future):
	¤ Use different tile sets
	¤ Some arenas contain obstacles / possibly hills
	¤ Arenas Voted as a possibility using 1 map with arenas throughout
