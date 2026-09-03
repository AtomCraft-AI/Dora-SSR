# Pattern: System Simulation

## Use When

The topic is a dynamic system with interacting variables, feedback, delays, resources, agents, or state transitions.

## Core Loop

Set conditions → predict → run/step → inspect state changes → compare strategy/conditions → explain system behavior.

## State Model

List state variables, update rules, constraints, time step, dependencies, and outputs. Label simplifications and probabilistic assumptions.

## Controls

Run/pause/step, speed, reset, scenario presets, key parameter controls, graph/history view, compare runs.

## Feedback

Show causal traces: which variable changed, what it influenced, and with what delay when relevant.

## Avoid

Opaque scores as the only output, instantaneous effects when the real concept depends on delay, or implying a simplified model predicts real-world outcomes exactly.
