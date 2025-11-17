# Celestial Knights - Developer Guide

## Configuration System

The game is designed to be highly configurable. All gameplay parameters are exposed through the `GameConfigResource` system.

### Editing Configuration

1. **In Godot Editor**:
   - Open `res://resources/configs/default_config.tres`
   - All parameters are exposed in the Inspector
   - Changes take effect immediately on next run

2. **Via Code**:
   ```gdscript
   # Access global config
   var config = GameConfig.get_config()

   # Modify values
   config.jetpack_acceleration = 40.0  # Increase to 4G
   config.missile_turn_rate = 180.0    # Faster missiles
   ```

3. **Runtime Console Commands**:
   - Press `/` or Enter in-game
   - Use commands like `/speed 2.0` to test changes

## Key Systems

### Heat Signature System

The signature system is the core gameplay mechanic:

```gdscript
# Heat generation
instant_signature = jetpack_active ? 200 MW : 0
accumulated_signature = accumulated_heat * signature_multiplier

# Decay formula
if not jetpack_active:
    signature *= exp(-decay_rate * time_since_off)
```

**Tuning Parameters**:
- `reactor_instant_heat`: Spike when jetpack active (default: 200 MW)
- `reactor_accumulated_heat`: Heat buildup rate (default: 6 MW)
- `passive_cooling_rate`: How fast heat dissipates (default: 2 MW/s)
- `exponential_decay_rate`: Decay speed (default: 0.5, half-life ~2s)

### Missile Guidance

Missiles use **proportional navigation**:

```gdscript
# Simplified guidance formula
desired_direction = (target_position - missile_position).normalized()
turn_strength = guidance_strength * detection_strength
turn_amount = min(turn_needed, max_turn_rate) * turn_strength
```

**Tuning for Hit Rates**:

To achieve **90% hit rate vs hot targets**:
- Increase `guidance_strength` (default: 3.0)
- Increase `missile_turn_rate` (default: 120°/s)
- Increase `lock_bonus_tracking` (default: 1.5)

To achieve **30% hit rate vs skiing targets**:
- Decrease `signature_tracking_mult` (default: 1.0)
- Ensure `lock_threshold_heat` is high enough (default: 150 MW)
- Balance cooling rate to allow signature to drop quickly

### Movement Physics

**Skiing** is achieved through friction manipulation:

```gdscript
# Normal ground friction
velocity = lerp(velocity, target_velocity, normal_friction * delta * 10.0)

# Skiing (low friction)
velocity = lerp(velocity, target_velocity, ski_friction * delta * 10.0)
```

**Key Parameters**:
- `normal_friction`: 0.8 (high grip)
- `ski_friction`: 0.05 (slides easily)
- `ski_air_control`: 0.3 (reduced control while skiing)

### Jetpack Physics

The jetpack provides constant acceleration with turn rate limiting:

```gdscript
# Apply thrust
thrust_direction = aim_direction.lerp(Vector3.UP, upward_bias)
velocity += thrust_direction * jetpack_acceleration * delta

# Turn rate limiting
max_turn = deg_to_rad(jetpack_turn_rate * delta)
new_direction = current_direction.slerp(desired_direction, max_turn)
```

**Feel Tuning**:
- `jetpack_acceleration`: Higher = faster ascent/movement (default: 29.4 m/s²)
- `jetpack_turn_rate`: Higher = more maneuverable (default: 90°/s)
- Increase both for arcade feel, decrease for realistic feel

## Creating Custom Loadouts

Loadouts modify base stats through multipliers:

```gdscript
# Example: Stealth loadout
var stealth_loadout = LoadoutConfig.new()
stealth_loadout.loadout_name = "Stealth Knight"
stealth_loadout.speed_modifier = 1.1          # 10% faster
stealth_loadout.heat_signature_modifier = 0.5  # 50% less visible
stealth_loadout.shield_modifier = 0.6          # 40% less shields
stealth_loadout.jetpack_fuel_modifier = 1.3    # 30% more fuel
```

Save as `.tres` file in `resources/configs/`.

## Balancing Guide

### Time-to-Kill (TTK)

Current TTK with AR-45:
- Base damage: 60 HP/shot
- Fire rate: 640 RPM (10.67 shots/s)
- Shield: 100 HP
- Health: 150 HP
- **Total: 250 HP**

Shots to kill: ~4.2 shots
TTK: ~0.4 seconds (optimal accuracy)

**Adjusting TTK**:
- Increase `damage_per_shot` for lower TTK
- Increase `shield_max` or `health_max` for higher TTK
- Adjust `fire_rate` for feel (640 RPM is similar to real AR)

### Missile Balance

Target hit rates:
- **90% vs hot targets** (constant jetpack use)
- **30% vs cold targets** (skiing with good management)

**If missiles are too strong**:
1. Reduce `missile_turn_rate`
2. Reduce `guidance_strength`
3. Increase `lock_on_time` (harder to lock)
4. Decrease `missile_speed`

**If missiles are too weak**:
1. Increase `missile_turn_rate`
2. Increase `lock_bonus_tracking`
3. Increase `missile_damage` or `missile_aoe_radius`

### Heat Management

Players should be encouraged to **burst** jetpack use:

**Current tuning**:
- Instant spike: 200 MW (immediately visible)
- Accumulated rate: 6 MW
- Cooling rate: 2 MW/s
- Lock threshold: 150 MW

**If jetpack is used too freely**:
- Increase `reactor_instant_heat` (bigger spike)
- Decrease `passive_cooling_rate` (slower recovery)
- Decrease `lock_threshold_heat` (easier to lock)

**If jetpack is used too cautiously**:
- Decrease `reactor_instant_heat`
- Increase `passive_cooling_rate`
- Increase `lock_threshold_heat`

## Performance Optimization

### Networking

The game uses client-server architecture:

**High Priority Sync** (every frame):
- Player position
- Player velocity
- Player rotation
- Jetpack state

**Medium Priority** (5 Hz):
- Heat signature
- Accumulated heat
- Power consumption

**Low Priority** (1 Hz):
- Fuel level
- Ammo count

**Event-based**:
- Damage events
- Weapon firing
- Missile launches

### Physics

For better performance:
- Missiles use `RigidBody3D` with simplified physics
- Players use `CharacterBody3D` for precise control
- Terrain uses `CSGShape3D` for easy editing (could be optimized to `StaticBody3D` + `MeshInstance3D`)

## Testing Workflow

### Single Player Testing

1. Launch game → "Single Player"
2. Test movement and feel
3. Use console commands to test edge cases:
   ```
   /refill              - Reset resources
   /speed 2.0           - Test at different speeds
   /heat 95             - Test near overheat
   /sig 200             - Test high signature
   ```

### Multiplayer Testing

1. **Host** on one instance
2. **Join** from another instance (use 127.0.0.1)
3. Test synchronization:
   - Movement smoothness
   - Hit detection
   - Missile tracking

### Automated Testing Ideas

```gdscript
# Create test scenarios
func test_missile_hit_rate():
    var hits = 0
    var total = 100

    for i in range(total):
        # Spawn player with high signature
        # Fire missile
        # Check if hit
        pass

    var hit_rate = float(hits) / float(total)
    assert(hit_rate >= 0.85 and hit_rate <= 0.95, "Hit rate should be ~90%")
```

## Common Issues and Solutions

### Issue: Player falls through floor
**Solution**: Ensure `CharacterBody3D` has `collision_layer = 2` and floor has `collision_mask = 1`

### Issue: Missiles don't track
**Solution**:
- Check `lock_threshold_heat` is appropriate
- Verify target has heat signature > threshold
- Check missile hasn't run out of fuel

### Issue: Camera clipping through terrain
**Solution**: Implement camera collision raycast (commented in player controller)

### Issue: Jetpack feels sluggish
**Solution**:
- Increase `jetpack_acceleration`
- Increase `jetpack_turn_rate`
- Reduce `body_lag_factor` for snappier controls

### Issue: Movement feels slippery
**Solution**:
- Increase `normal_friction`
- Reduce `air_control`
- Adjust `body_lag_factor`

## Extending the Game

### Adding New Weapons

1. Create weapon script in `scripts/weapons/`
2. Inherit from base weapon class (or create one)
3. Add to player's weapon inventory
4. Create config entries in `GameConfigResource`

### Adding New Signature Types

The framework exists for:
- **Radar signature** (ECM/ECCM systems)
- **Visual signature** (cloaking)
- **Aura signature** (magic/energy detection)

To implement:

```gdscript
# In player_controller.gd
func calculate_total_signature() -> float:
    var sig = calculate_heat_signature()
    sig += calculate_radar_signature()
    sig += calculate_visual_signature()
    sig += calculate_aura_signature()
    return sig
```

Add config parameters and implement detection logic.

### Adding Game Modes

Create new scene inheriting from `game_world.tscn`:
- Capture the Flag: Add flag objects and capture zones
- King of the Hill: Add control point areas
- Team Deathmatch: Already supported, add score limit

## Formula Reference

### Heat Signature Calculation

```
instant_signature = jetpack_active ? reactor_instant_heat : 0
accumulated_signature = accumulated_heat * heat_signature_multiplier

if not jetpack_active:
    decay_factor = exp(-exponential_decay_rate * time_since_jetpack_off)
    instant_signature *= decay_factor

total_signature = instant_signature + accumulated_signature
```

### Damage Falloff

```
if distance > damage_falloff_start:
    falloff_range = damage_falloff_end - damage_falloff_start
    falloff_amount = (distance - damage_falloff_start) / falloff_range
    falloff_amount = clamp(falloff_amount, 0, 1)
    damage *= lerp(1.0, 0.5, falloff_amount)  # 50% damage at max range
```

### Proportional Navigation (Missiles)

```
to_target = target.position - missile.position
desired_direction = to_target.normalized()

# Predict target position
time_to_intercept = distance / missile_speed
predicted_position = target.position + target.velocity * time_to_intercept
desired_direction = (predicted_position - missile.position).normalized()

# Apply turn with signature strength
detection_strength = target.signature / lock_threshold
turn_strength = guidance_strength * detection_strength
turn_amount = min(turn_needed, max_turn_rate * delta) * turn_strength
```

## Debug Visualization

Add to `player_controller.gd` for debugging:

```gdscript
func _draw_debug():
    # Draw heat signature as sphere radius
    var debug_sphere = ImmediateMesh.new()
    var radius = heat_signature / 100.0  # Scale for visibility
    # Draw sphere with radius proportional to signature

    # Draw missile lock cone
    # Draw velocity vector
    # etc.
```

## Contact and Contributing

This game is designed to be easily moddable. All systems are exposed and documented. Feel free to:
- Adjust configurations
- Create new loadouts
- Add weapons
- Implement new signature types
- Create game modes

---

**Last Updated**: 2025-11-17
**Version**: 1.0
**Engine**: Godot 4.2+
