# Physics

## Learning Actions

Set initial conditions, manipulate physical parameters, observe motion/fields/light/circuits, measure, plot, compare trials, and infer relationships.

## Strong Patterns

- [Virtual lab](@agent-skill/builtin/creating-educational-interactives/patterns/virtual-lab.md)
- [System simulation](@agent-skill/builtin/creating-educational-interactives/patterns/system-simulation.md)
- [Interactive visualization](@agent-skill/builtin/creating-educational-interactives/patterns/interactive-visualization.md)

## State Model

Define variables with units, valid ranges, equations/constraints, and dependencies. Visual motion, vectors, graphs, and numeric readouts must agree.

## Design Rules

- Let learners pause, step, reset, and overlay trials.
- Use vectors/arrows only when their magnitude and direction are meaningful.
- Prefer real measurement tasks over “watch the animation.”
- For circuits, topology must determine current/voltage behavior; for optics, object/lens changes must alter ray paths and image formation; for mechanics, initial conditions must alter trajectory dynamically.

## Feedback

When a prediction fails, compare predicted vs observed values or trajectories and point to the relevant variable.

## Avoid

Preset animations that ignore controls, inconsistent units, impossible energy gains, or graph traces disconnected from the simulated object.
