# ToDo (Issues to fix):
- ArpgPlayerController is exploding at start of game
    - This is because ArpgGameInfo is spawning a hero pawn immediately at login
    - Also appears that PlayerController loses input control immediately sometimes

- Hero pawn possession needs to be validated
    - Reset the inventory UI
    - Ensure player controller and camera lock on correctly
    - Make sure the old pawn (if there was one) is properly released

- Route player input to either the UI or the player, but not both
    - Right now, when you click in inventory the hero will attack or move
    - Need to disable looking, turning, attacking, etc

# ToDo (Things to add):
- Pawn item containers update the items attached to him
    - When an item slot changes, it needs to change the item actor the pawn is holding

- Pawn animation needs to be set up
    - The 8-way run and walk animations need to be set up
    - Some system for picking animation set based on weapon

- Attribute system
    - This is a work in progress

- Networked Item sessions
    - This is gonna be hard, might have to be in a later release