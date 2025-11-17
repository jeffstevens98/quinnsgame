# Celestial Knights - Quick Start Guide

## Prerequisites

- **Godot Engine 4.2 or higher** ([Download here](https://godotengine.org/download))
- No additional dependencies required

## Opening the Project

1. Launch Godot Engine
2. Click "Import"
3. Navigate to the project folder and select `project.godot`
4. Click "Import & Edit"

## First Launch

### Single Player (Recommended for first time)

1. Run the project (F5 or press the Play button)
2. Click **"Single Player"** on the main menu
3. You'll spawn in a test arena

### Controls Quick Reference

**Movement**:
- `W/A/S/D` - Move
- `Shift` - Sprint
- `Space (tap)` - Jump
- `Space (hold)` - Jetpack
- `Ctrl (hold)` - Ski mode

**Combat**:
- `Mouse` - Aim
- `Left Click` - Shoot
- `G (hold)` - Lock missile
- `G (release)` - Fire missile

**UI**:
- `Tab` - Scoreboard
- `/` or `Enter` - Console
- `Esc` - Toggle mouse

## Your First Game

### Movement Tutorial

1. **Walking**: Use WASD to move around
2. **Sprinting**: Hold Shift while moving (50% speed boost)
3. **Jumping**: Tap Space for a small jump
4. **Jetpack**: Hold Space to fly upward
   - While holding W: Fly forward in aim direction
   - Watch your fuel gauge (top right)

5. **Skiing** (Advanced):
   - Hold Ctrl while moving
   - Build speed by sliding down hills
   - Use jetpack to gain altitude, then ski down
   - This is the fastest way to travel!

### Heat Management

Watch the **Heat Gauge** (bottom center):
- Using jetpack generates heat
- High heat makes you visible to missiles
- Heat cools down when jetpack is off
- Try to fly in short bursts

### Combat Basics

1. **Shooting**:
   - Aim with mouse
   - Hold Left Click to fire
   - Press R to reload

2. **Missiles**:
   - Aim at an enemy
   - Hold G until "LOCKED" appears (~2 seconds)
   - Release G to fire
   - **Note**: Can only lock enemies with high heat (using jetpack)

### Console Commands

Press `/` or `Enter` and try these:

- `/refill` - Restore all resources
- `/speed 2.0` - Move twice as fast (testing)
- `/heat 0` - Reset heat to zero

## Testing with AI Bots

You can spawn AI bots to practice against:

1. Press `/` or `Enter` to open the console
2. Type `/spawnbot` to spawn one bot
3. Or type `/spawnbot 5` to spawn 5 bots
4. Bots will automatically patrol, chase, and attack

Bots have different skill levels and will use jetpacks, weapons, and missiles just like players!

## Multiplayer

### Hosting a Game

1. Main menu → Enter a port (default: 7777)
2. Click **"Host Game"**
3. Share your IP with friends

### Joining a Game

1. Main menu → Enter host's IP address
2. Enter the port (default: 7777)
3. Click **"Join Game"**

### LAN Play

- Host: Use default settings
- Join: Enter `127.0.0.1` for same machine, or host's local IP (e.g., `192.168.1.100`)

## Tips for New Players

### Movement Tips

1. **Skiing is your friend**: The fastest players ski down hills and use short jetpack bursts
2. **Manage your fuel**: You have 20 minutes of fuel total, but it's easy to waste
3. **Dive roll**: Press Alt while moving to dive, then Alt again before landing for a cool roll

### Combat Tips

1. **Heat awareness**: Flying makes you a missile target
2. **Lock on hot targets**: You can only lock missiles on enemies actively using jetpacks
3. **Evade missiles**: Stop jetpacking and ski to reduce your signature when you hear the warning
4. **Close range**: The rifle is most effective under 50m

### Heat Signature Strategy

- **High signature** (~200+ MW):
  - Constant jetpack use
  - Easy missile target
  - Maximum mobility

- **Low signature** (~0-50 MW):
  - Skiing only
  - Missile-safe
  - Limited vertical movement

- **Burst flight** (recommended):
  - Short jetpack bursts
  - Ski between bursts
  - Balance of mobility and stealth

## Troubleshooting

### Mouse is locked/unlocked incorrectly
- Press `Esc` to toggle mouse capture mode

### Can't lock missile on enemy
- They must be using their jetpack (high heat signature)
- You must keep crosshair on them for 2 seconds
- They must be within 300m

### Framerate drops
- The game uses placeholder CSG shapes which aren't optimized
- Reduce window size or play windowed
- Future updates will add proper optimized models

### Can't connect in multiplayer
- Check firewall settings
- Ensure correct IP and port
- Host may need to port forward (not needed for LAN)

## Next Steps

1. **Learn skiing**: Practice on the ramps and hills
2. **Master heat management**: Try to stay cool while staying mobile
3. **Try different loadouts**: Edit config files or create custom loadouts
4. **Read the full README**: Detailed mechanics and strategies
5. **Check DEVELOPER_GUIDE**: Learn to modify and tune the game

## Customization

Want to change game settings?

1. In Godot editor: `res://resources/configs/default_config.tres`
2. All parameters are exposed in the Inspector
3. Changes take effect on next game launch

## Feedback

Found a bug or have suggestions?
- Check the issues on GitHub
- Modify the game yourself (highly configurable!)

---

**Have fun and ski fast!**

The game is designed for high-speed, strategic movement combined with tactical heat management. The faster you go, the more fun you'll have, but the more vulnerable you become to missiles. Find your balance!
