# Built-in vs MCP claude-teams: Multi-Agent Comparison

This document explains the two approaches for running multiple AI agents in Claude Code.

## Overview

When working with Claude Code, there are two strategies for orchestrating multiple agents to work in parallel on different tasks:

1. **Built-in (TeamCreate/Task)** — Native subagents running within the same session
2. **MCP (claude-teams)** — Separate Claude Code processes running in tmux panes

## Comparison Table

| Aspect | Built-in (TeamCreate/Task) | MCP (claude-teams) |
|---|---|---|
| **Agent runtime** | Subagents within this session | Separate Claude Code processes in tmux panes |
| **Observability** | Messages appear inline | `tmux attach` to watch agents live |
| **Message delivery** | Automatic (teammate-message) | Manual polling (`poll_inbox`) |
| **Setup** | Zero config | Requires tmux session running |
| **Spawning** | Instant | ~2-3s per agent (tmux + CLI startup) |
| **Result delivery** | Push (messages arrive automatically) | Pull (must poll for results) |
| **Team cleanup** | TeamDelete | `force_kill` + `team_delete` |
| **Reliability** | Stable | Needed tmux troubleshooting |
| **Agent isolation** | Shared context window budget | True process isolation |

## When to Use Each Approach

### Use Built-in (TeamCreate/Task) when:
- Tasks are simple to moderate in complexity
- You need fast agent creation and automatic result delivery
- Zero configuration is preferred
- Shared context window is sufficient for all agents

### Use MCP (claude-teams) when:
- Tasks are complex and each agent needs its own full context window
- You want true process isolation between agents
- You need to observe agents working in real-time via tmux
- You need independent agent lifecycles

## Key Trade-offs

- **Built-in** prioritizes simplicity and speed, but agents share a limited context window
- **MCP claude-teams** provides full isolation and observability, but requires more setup and maintenance
