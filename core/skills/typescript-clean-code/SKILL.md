---
name: typescript-clean-code
description: Enforces strict TypeScript typing, SOLID principles, clean abstractions, and idiomatic patterns. Use when writing TypeScript code, reviewing .ts or .tsx files, designing interfaces, working with generics or utility types, or when the user mentions TypeScript, type safety, strict mode, interfaces, or type errors.
allowed-tools: Read, Grep, Glob, Bash(tsc *), Bash(eslint *)
---

# TypeScript clean code

## Baseline config (always strict: true)
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true
  }
}
```

## Types vs interfaces

| Use | When |
|---|---|
| `interface` | Object shapes, class contracts, extendable |
| `type` | Unions, intersections, mapped types, computed aliases |

## Dependency inversion
```typescript
interface OrderRepository {
  findById(id: string): Promise<Order | null>
  save(order: Order): Promise<void>
}

class OrderService {
  constructor(private readonly repo: OrderRepository) {}
}
```

## Null safety
```typescript
type Result<T, E = Error> =
  | { ok: true; data: T }
  | { ok: false; error: E }

function isUser(v: unknown): v is User {
  return typeof v === 'object' && v !== null && 'id' in v
}
```

## Exhaustive switch
```typescript
function assertNever(x: never): never {
  throw new Error(`Unhandled: ${x}`)
}

function label(status: OrderStatus): string {
  switch (status) {
    case 'pending': return 'Waiting'
    case 'shipped': return 'On the way'
    default: return assertNever(status)
  }
}
```

## Enums → as const
```typescript
const OrderStatus = {
  Pending: 'pending',
  Shipped: 'shipped',
} as const
type OrderStatus = typeof OrderStatus[keyof typeof OrderStatus]
```

## Utility types
```typescript
type CreateUserDto = Omit<User, 'id' | 'createdAt'>
type UpdateUserDto = Partial<Pick<User, 'name' | 'email'>>
```

## Gotchas

- `any` disables the type checker entirely — use `unknown` + type guard instead.
- `as SomeType` casts lie — prefer type guards that actually verify shape.
- `!` non-null assertions — each one is a potential runtime crash.
- `a?.b ?? 'default'` ≠ `a?.b || 'default'` — the latter treats 0 and '' as falsy.
- `exactOptionalPropertyTypes`: `{ name?: string }` does NOT accept `{ name: undefined }`.
- `noUncheckedIndexedAccess`: array indexing `arr[0]` becomes `T | undefined` — handle it.
