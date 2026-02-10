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

## Usage Guide

### 1. Built-in Agent Teams

Enable in `.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "auto"
}
```

Then ask Claude in natural language to create a team:

```
Create an agent team:
- One teammate to review security
- One teammate to optimize performance
- One teammate to write tests
```

Keyboard shortcuts:
- **Shift+Up/Down** — switch between teammates
- **Type + Enter** — send a direct message to a teammate
- **Ctrl+T** — view shared task list

Clean up when done: `Clean up the team`

### 2. Subagents (lightweight)

Create an agent file at `~/.claude/agents/my-agent.md`:

```markdown
---
name: my-agent
description: Description of what this agent does
tools: Read, Grep, Glob, Bash
model: sonnet
---

System prompt for the agent goes here.
```

Then invoke: `Use the my-agent agent on this project`

Or create interactively: `/agents` → "Create new agent"

### 3. MCP claude-teams

Install prerequisites:

```bash
sudo apt-get install tmux   # Linux
brew install tmux            # macOS
```

Add the MCP server:

```bash
claude mcp add --transport stdio claude-teams -- \
  uvx --from git+https://github.com/cs50victor/claude-code-teams-mcp claude-teams
```

Set teammate mode to tmux in `.claude/settings.json`:

```json
{
  "teammateMode": "tmux"
}
```

Watch agents live: `tmux attach`
