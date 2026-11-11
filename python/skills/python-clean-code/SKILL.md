---
name: python-clean-code
description: Enforces SOLID principles, PEP 8, type hints, clean abstractions, and concise idiomatic Python. Use when writing Python code, reviewing Python files, creating new .py modules, refactoring Python, or when the user mentions Python style, clean code, type hints, dataclass, abstract class, or PEP 8.
allowed-tools: Read, Grep, Glob, Bash(python *), Bash(ruff *), Bash(mypy *)
---

# Python clean code

## Core rules

- One responsibility per function and class. If you need "and" to describe it, split it.
- Type-annotate everything. Functions without return types are incomplete.
- Inject dependencies. Never instantiate concrete classes inside other classes.
- Short functions. Aim ≤ 20 lines.
- Flat is better than nested. Use early returns, not deep if-else trees.

## SOLID quick reference

### Single responsibility
```python
class InvoiceGenerator:
    def generate(self, order: Order) -> Invoice: ...

class InvoiceMailer:
    def send(self, invoice: Invoice, recipient: str) -> None: ...
```

### Open/closed
```python
from abc import ABC, abstractmethod

class Notifier(ABC):
    @abstractmethod
    def notify(self, message: str) -> None: ...

class EmailNotifier(Notifier): ...
class SlackNotifier(Notifier): ...
```

### Dependency inversion
```python
from typing import Protocol

class OrderRepository(Protocol):
    def find(self, id: str) -> Order | None: ...
    def save(self, order: Order) -> None: ...

class OrderService:
    def __init__(self, repo: OrderRepository) -> None:
        self.repo = repo
```

## Type hints
```python
def find_user(id: int) -> User | None: ...
def process(items: list[str], config: dict[str, int]) -> None: ...

from dataclasses import dataclass

@dataclass(frozen=True)
class UserId:
    value: str
```

## Enums over raw strings
```python
from enum import StrEnum

class OrderStatus(StrEnum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    SHIPPED = "shipped"
```

## Gotchas

- Mutable default arguments: `def f(items=[])` is a trap. Use `None` and assign inside.
- Bare `except:` silences everything including `KeyboardInterrupt`. Always catch specific exceptions.
- Use `isinstance()` not `type()` — it respects inheritance.
- Comments explain *why*, not *what*. If you need a comment to explain what, rename the code.
- `StrEnum` (Python 3.11+) is directly comparable to strings without `.value`.
- `@dataclass(frozen=True)` makes instances hashable and immutable — use for value objects.
