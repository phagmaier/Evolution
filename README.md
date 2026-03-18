# Zig Evolution Toy Simulation

A small, chaotic, and mildly philosophical agent-based simulation written in Zig.

Agents wander a grid, eat, fight, reproduce, and die. Over time, simple genetic traits evolve under pressure from resource scarcity, competition, and random mutation. The result is a noisy but interesting system where different behavioral strategies emerge and collapse.

There is also a Python script (`main.py`) for visualizing the output as graphs.

---

## What This Is

This is a grid-based evolutionary simulation with:

* Autonomous agents
* Simple genetic traits
* Local decision-making (no global intelligence)
* Emergent behavior over many iterations

Agents are not "smart" in any meaningful sense—they just optimize a scoring function based on their genome and surroundings. The interesting part is what happens when you let that run for a long time.

---

## Core Concepts

### Agents

Each agent has:

* Energy (life resource)
* Age (death condition)
* Location (grid position)
* Genome (behavior parameters)

### Genome Traits

Each trait is a float in `[0, 1]`:

* `aggression` — tendency to fight
* `greed` — tendency to compete instead of share
* `speed` — movement range (costs energy)
* `perception` — vision radius (costs energy)
* `sociability` — preference for groups
* `food_priority` — preference for food over other incentives

These traits directly influence movement, combat, reproduction, and survival.

---

## World

* 2D toroidal grid (wraps around edges)
* Each tile may contain:

  * Food
  * Multiple agents

Each tick:

* Food spawns randomly
* Agents move based on local scoring
* Tile interactions occur

---

## Agent Behavior

### Movement

Agents scan nearby tiles and score them based on:

* Food presence
* Number of agents (social vs aggressive bias)
* Distance penalty

They move to the highest-scoring location.

---

### Tile Interactions

When multiple agents occupy a tile:

* **Food handling**

  * Single agent → eats
  * Multiple agents → share or compete depending on greed

* **Conflict**

  * Aggressive agents may trigger fights
  * Winners gain energy, losers lose it (or die)

* **Reproduction**

  * High-energy agents reproduce
  * Traits are inherited with occasional mutation

---

### Energy System

Agents lose energy each turn based on:

* Base drain
* Movement capability (speed)
* Vision (perception)

They gain energy from:

* Eating food
* Winning fights

Agents die if:

* Energy reaches 0
* Age exceeds max limit

---

## Evolution Dynamics

There is no explicit fitness function.

Selection pressure emerges from:

* Resource scarcity
* Competition
* Survival costs (movement + perception)
* Reproduction thresholds

Over time you’ll typically see:

* Aggressive populations rise and collapse
* Cooperative clusters form and get exploited
* Oscillations between strategies

It’s unstable by design.

---

## Data Output

After the simulation, a file `data.txt` is written containing time-series data:

* Population
* Births / deaths
* Average traits
* Average energy / age
* Behavioral breakdown:

  * Predators
  * Foragers
  * Social agents
  * Drifters

Each line is a labeled array over all epochs.

---

## Visualization (Python)

A `main.py` script is included to generate graphs using matplotlib.

Typical plots:

* Population over time
* Trait averages
* Strategy distribution
* Energy dynamics

Run it after generating `data.txt` to visualize the simulation.

---

## How to Run

### Debug

```
zig build run
```

### Optimized (Release)

```
zig build -Doptimize=ReleaseFast run
```

Or directly:

```
zig run main.zig -O ReleaseFast
```

---

## Configuration

All simulation parameters live in `constants.zig`, including:

* Grid size
* Initial population
* Energy values
* Reproduction thresholds
* Mutation behavior
* Food spawn rate

Changing these significantly alters system behavior.

---

## Notes

* Memory is manually managed; agents are heap-allocated.
* The world uses a toroidal grid (wrap-around movement).
* Simulation length is currently set very high (100k epochs).
* Behavior is intentionally noisy and not “balanced.”

---

## Why This Exists

This is not a serious scientific model.

It’s a sandbox for:

* Playing with emergent behavior
* Observing simple evolutionary dynamics
* Stress-testing ideas about local decision systems

It’s also just fun to watch the system spiral into weird equilibria.

---

## Possible Extensions

* Add terrain types
* Introduce diseases or environmental hazards
* More complex reproduction (multi-parent, crossover)
* Neural policies instead of fixed heuristics
* Visualization in real-time instead of post-processing

---

## License

Do whatever you want with it.
