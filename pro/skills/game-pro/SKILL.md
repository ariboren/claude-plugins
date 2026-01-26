---
name: game-pro
description: Game development expertise for engine programming, graphics optimization, physics simulation, and multiplayer networking. Use when building games, optimizing performance, implementing game mechanics, or designing game architecture.
---

# Game Development Expertise

## Performance Targets

- 60 FPS stable (16.67ms frame budget)
- Load time < 3 seconds
- Memory within platform limits
- Network latency < 100ms for multiplayer
- Crash rate < 0.1%

## Game Architecture

Entity Component Systems:

- Entities are IDs, not objects
- Components are pure data
- Systems process component groups
- Enables cache-friendly iteration
- Easy serialization and networking

Scene Management:

- Scene graphs for spatial organization
- Level streaming for large worlds
- Async loading with loading screens
- Memory budgets per scene

State Machines:

- Game states (menu, playing, paused)
- Character states (idle, running, jumping)
- AI behavior states
- Animation state machines

## Graphics Programming

Rendering Pipeline:

- Culling (frustum, occlusion)
- Batching draw calls
- LOD (Level of Detail) systems
- Deferred vs forward rendering

Shader Development:

- Vertex/fragment shader basics
- Surface shaders for materials
- Compute shaders for GPU work
- Shader variants and keywords

Optimization:

- Draw call batching
- Texture atlasing
- Instanced rendering
- GPU profiling

## Physics Simulation

Collision Detection:

- Broad phase (spatial hashing, BVH)
- Narrow phase (GJK, SAT)
- Collision layers and masks
- Trigger volumes vs colliders

Rigid Body Dynamics:

- Integration methods (Verlet, RK4)
- Constraint solving
- Sleep states for performance
- Fixed timestep simulation

Optimization:

- Simplified collision shapes
- Physics LOD (reduce simulation distance)
- Async physics on separate thread
- Continuous collision for fast objects

## AI Systems

Pathfinding:

- Navigation mesh generation
- A\* for path queries
- Path smoothing
- Dynamic obstacle avoidance

Behavior Trees:

- Composites (sequence, selector, parallel)
- Decorators (inverter, repeater)
- Leaf nodes (actions, conditions)
- Blackboard for shared state

Decision Making:

- Utility-based AI
- GOAP (Goal-Oriented Action Planning)
- Finite state machines
- Influence maps

## Multiplayer Networking

Architecture:

- Client-server for competitive games
- Peer-to-peer for small scale
- Dedicated servers for reliability
- Matchmaking and lobbies

State Synchronization:

- Authoritative server model
- Client-side prediction
- Server reconciliation
- Entity interpolation

Lag Compensation:

- Input delay buffering
- Rollback networking
- Lag compensation for hit detection
- Network jitter handling

Optimization:

- Delta compression
- Interest management (only send relevant data)
- Variable update rates
- Prioritized message sending

## Engine-Specific Patterns

### Unity

```csharp
// Object pooling
public class ObjectPool<T> where T : Component {
    private Queue<T> pool = new Queue<T>();

    public T Get() {
        return pool.Count > 0 ? pool.Dequeue() : CreateNew();
    }

    public void Return(T obj) {
        obj.gameObject.SetActive(false);
        pool.Enqueue(obj);
    }
}
```

### Unreal Engine

```cpp
// Actor component pattern
UCLASS()
class UHealthComponent : public UActorComponent {
    GENERATED_BODY()

    UPROPERTY(EditAnywhere)
    float MaxHealth = 100.f;

    UPROPERTY(ReplicatedUsing=OnRep_Health)
    float Health;

    UFUNCTION()
    void OnRep_Health();
};
```

## Performance Optimization

CPU Optimization:

- Profile before optimizing
- Cache-friendly data layouts
- Avoid allocations in hot paths
- Job system for parallelism

GPU Optimization:

- Reduce overdraw
- Optimize shader complexity
- Use LODs aggressively
- Batch similar materials

Memory Optimization:

- Object pooling
- Asset streaming
- Memory budgets per system
- Texture compression

## Mobile Considerations

Performance:

- Thermal throttling awareness
- Battery efficiency
- Reduced polygon counts
- Simplified shaders

Memory:

- Strict memory budgets
- Texture compression formats
- Asset bundles for on-demand loading
- Background unloading

Input:

- Touch controls and gestures
- Virtual joysticks
- Gyroscope integration
- Haptic feedback

## Platform Certification

Console Requirements:

- TRC/XR compliance
- Suspend/resume handling
- Achievement integration
- Save data management

Store Requirements:

- Content ratings
- Privacy policies
- Age verification
- Purchase flow compliance

## Quality Checklist

- [ ] 60 FPS stable maintained
- [ ] Load time < 3 seconds achieved
- [ ] Memory usage optimized properly
- [ ] Network latency < 100ms ensured
- [ ] Crash rate < 0.1% verified
- [ ] Asset size minimized efficiently
- [ ] Battery usage efficient consistently
- [ ] Platform requirements met
