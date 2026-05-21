# Restricted ERC20 Token (Starknet)

A simple ERC20 token on Starknet with transfer limits and admin controls. Built with Cairo and [Scarb](https://docs.swmansion.com/scarb/).

## Features

| Feature | Description |
|---------|-------------|
| **ERC20** | `transfer`, `approve`, `transfer_from`, balances, supply |
| **Transfer cap** | Each transfer must be ≤ `max_limit` (default **10,000**) |
| **Admin** | Set at deploy via constructor — not the UDC deployer |
| **Revoke** | User who approved can cancel their allowance (`revoke`) — [revoke.cash](https://revoke.cash) style |
| **Admin burn** | Owner can destroy tokens from any address |
| **Update limit** | Owner can change `max_limit` |



## Build & test

```bash
scarb build
scarb test
```

## Deploy (constructor args)

Pass addresses and token settings in this order:

1. `admin` — admin address (stored as `owner`)
2. `recipient` — initial token holder
3. `name` — token name (felt252)
4. `symbol` — ticker (felt252)
5. `decimals` — e.g. `18`
6. `initial_supply` — tokens minted to `recipient`

Contract module name for declare: **`ERC20Token`**

## Who can call what

| Function | Caller |
|----------|--------|
| `transfer`, `approve`, `revoke` | Any token holder |
| `transfer_from` | Approved spender |
| `burn`, `set_max_limit` | Admin (`owner`) |
| `get_owner`, `balance_of`, … | Anyone (read-only) |

