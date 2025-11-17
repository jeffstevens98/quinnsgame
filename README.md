# Celestial Knights

A multiplayer 3rd-person sci-fi combat game built in Godot 4 featuring jetpack-equipped armored warriors, Tribes Ascend-style skiing mechanics, and signature-based heat-seeking missiles.

## Overview

Celestial Knights combines fast-paced movement with strategic heat management. Players are armored warriors equipped with:
- **Jetpacks** for flight and mobility
- **Skiing mechanics** for momentum-based traversal
- **AR-45 "Liberator"** assault rifle
- **Heat-seeking missiles** that lock onto thermal signatures
- **Signature-based detection** where jetpack use makes you targetable

## Features

### Phase 1 - Core Gameplay (Implemented)
✅ Third-person camera system (Helldivers 2 style)
✅ Advanced movement: WASD, sprint, crawl, dive, skiing, jetpack flight
✅ Power reactor and heat management system
✅ Shields and health with regeneration
✅ AR-45 Liberator weapon with melee attacks
✅ Heat signature calculation and tracking
✅ Missile lock-on and guidance system
✅ Comprehensive HUD showing all resources

### Phase 2 - Multiplayer (Implemented)
✅ Host/Join networking system
✅ Team-based gameplay (Red vs Blue)
✅ Player synchronization
✅ Chat commands for testing
✅ Scoreboard with stats tracking

### Phase 3 - Combat (Implemented)
✅ Full damage system
✅ Hit detection
✅ Death and respawn
✅ Kill/death tracking

### Phase 4 - Polish (Implemented)
✅ Multiple loadouts (Light, Standard, Heavy)
✅ Configuration system for easy tuning
✅ Chat console for debug commands

## Controls

### Movement
- **W/A/S/D**: Move
- **Shift**: Sprint
- **Spacebar (tap)**: Jump
- **Spacebar (hold)**: Activate jetpack
- **Ctrl**: Skiing mode (low friction)
- **C**: Toggle crawl/prone
- **Alt**: Dive/leap (press again before landing for handspring)

### Combat
- **Mouse**: Aim
- **Left Click**: Fire weapon
- **R**: Reload
- **Mouse Wheel Up**: Stab (melee)
- **Mouse Wheel Down**: Butt strike (melee)
- **G (hold)**: Lock missile onto target
- **G (release)**: Fire missile when locked

### UI
- **Tab**: Show scoreboard
- **Enter or /**: Open chat console
- **Escape**: Toggle mouse capture

## Heat Signature System

The signature system is central to gameplay:

- **Jetpack use generates instant heat** (200 MW signature)
- **Accumulated heat** adds to your signature
- **Passive cooling** reduces heat when not using jetpack
- **Missiles lock onto targets above 150 MW signature**
- **Strategic gameplay**: Balance mobility vs stealth

### Signature Management Tips
1. **Short jetpack bursts** minimize signature spikes
2. **Skiing** maintains momentum without heat generation
3. **Cool down** between engagements to reduce detectability
4. **Use terrain** to break line of sight when cooling

## Loadouts

### Light Knight
- 30% faster movement speed
- 30% reduced heat signature
- 20% more jetpack fuel
- 30% less shields
- 20% less health

### Standard Knight (Balanced)
- Baseline stats
- Versatile for all playstyles

### Heavy Knight
- 50% more shields
- 30% more health
- 20% more weapon damage
- 30% slower movement
- 40% higher heat signature

## Missile System

Missiles use **proportional navigation** with signature-based tracking:

1. **Lock-on**: Hold G with crosshair on target (2 seconds)
2. **Fire**: Release G when "LOCKED" appears
3. **Tracking**: Missile follows heat signature
4. **Evasion**: Reduce signature by skiing and managing heat

### Hit Rates (Target)
- **90%** vs player in sustained jetpack flight
- **30%** vs player skiing with good heat management

## Chat Commands (Testing)

Access via Enter or / key:

- `/team [1/2]` - Switch teams
- `/refill` - Restore all resources
- `/speed [multiplier]` - Adjust movement speed
- `/heat [value]` - Set accumulated heat
- `/sig [value]` - Set heat signature
- `/cooldown [multiplier]` - Adjust cooling rate
- `/godmode` - Toggle invincibility (not implemented)
- `/noclip` - Toggle collision (not implemented)

## Configuration

All game parameters are configurable in `GameConfigResource`:

### Key Tunable Values
- **Jetpack acceleration**: 29.4 m/s² (3G)
- **Jetpack fuel**: 5kg (20 min continuous use)
- **Heat signature threshold**: 150 MW for missile lock
- **Missile turn rate**: 120°/s
- **Guidance strength**: Configurable proportional navigation
- **Shield/Health regen rates**: Independent timers
- **Weapon stats**: Damage, fire rate, spread, recoil

## Project Structure

```
celestial_knights/
├── scenes/           # All scene files (.tscn)
├── scripts/          # GDScript files
│   ├── autoload/    # Singleton managers
│   ├── player/      # Player controller
│   ├── weapons/     # Weapon and missile systems
│   ├── systems/     # Core game systems
│   └── ui/          # HUD and menus
├── resources/       # Config and data files
│   ├── configs/     # Loadout configurations
│   └── formulas/    # Signature calculation formulas
└── assets/          # Models, textures, sounds, particles
```

## Technical Details

### Physics
- Gravity: 9.8 m/s²
- Skiing friction: 0.05 (vs normal 0.8)
- Jetpack: 3G acceleration with turn rate limiting
- Proportional navigation for missiles

### Networking
- Client-server architecture
- Server-authoritative hit detection
- Client-side prediction for movement
- ENet multiplayer peer (up to 16 players)

### Resource Management
- **Shields**: Fast regeneration (10 HP/s after 3s)
- **Health**: Slow regeneration (2 HP/s after 8s)
- **Heat**: Passive cooling at 2 MW/s
- **Fuel**: Gradual consumption during flight

## How to Play

### Single Player (Testing)
1. Launch game
2. Click "Single Player"
3. Use `/refill` to restore resources during testing
4. Experiment with movement and heat management

### Multiplayer
1. **Host**: Enter port, click "Host Game"
2. **Join**: Enter IP and port, click "Join Game"
3. Auto-assigned to balanced teams
4. Respawn after 3 seconds on death

## Development Roadmap

### Future Enhancements (Phase 4+)
- [ ] Advanced signature types (radar, visual, aura)
- [ ] ECM/ECCM systems
- [ ] Cloaking mechanics
- [ ] Additional weapons
- [ ] More loadout customization
- [ ] Game modes (Capture the Flag, King of the Hill)
- [ ] Proper 3D models and animations
- [ ] Sound effects and music
- [ ] Particle effects for all systems

## Credits

Built with Godot 4.2+ Engine
Inspired by:
- Tribes Ascend (skiing mechanics)
- Helldivers 2 (camera and feel)
- Heat signature detection systems

## License

This is a game development project. All configuration values are exposed for easy modding and balancing.

---

**Version**: 1.0 (Phase 1-3 Complete)
**Engine**: Godot 4.2+
**Genre**: Multiplayer Third-Person Shooter
**Status**: Playable MVP
