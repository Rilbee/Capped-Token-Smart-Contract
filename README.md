# Capped Token Contract

A robust, secure, and feature-rich fungible token smart contract built on the Stacks blockchain using Clarity. This contract implements a supply-capped token with comprehensive administrative controls and security features.

## Overview

The Capped Token Contract is a fully SIP-010 compliant fungible token with a maximum supply limit of 1 billion tokens (1,000 tokens with 6 decimal places). It includes advanced features like role-based access control, blacklist functionality, emergency pause mechanisms, and bulk operations.

## Token Specifications

- **Name**: Capped Token
- **Symbol**: CAP  
- **Decimals**: 6
- **Max Supply**: 1,000,000,000 (1 billion micro-tokens = 1,000 tokens)
- **Standard**: SIP-010 Compliant

## Key Features

### Core Functionality
- **Minting**: Controlled token creation by authorized minters
- **Burning**: Token holders can burn their own tokens
- **Transfers**: Standard and bulk transfer operations
- **Supply Cap**: Hard limit prevents over-minting

### Security Features
- **Role-Based Access**: Owner and minter role management
- **Blacklist System**: Block specific addresses from token operations
- **Pause Mechanism**: Emergency contract pause functionality
- **Ownership Transfer**: Secure ownership transition capability

### Administrative Controls
- **Minter Management**: Add/remove authorized minters
- **User Management**: Blacklist/unblacklist addresses
- **Contract Control**: Pause/unpause operations
- **Metadata**: Set token URI for additional information

## Function Reference

### SIP-010 Standard Functions

#### `transfer(amount, sender, recipient, memo)`
Transfer tokens between addresses.
- **Parameters**: amount (uint), sender (principal), recipient (principal), memo (optional buff)
- **Returns**: (response bool uint)
- **Restrictions**: Not paused, parties not blacklisted

#### `get-balance(user)`
Get token balance for a specific address.
- **Parameters**: user (principal)
- **Returns**: (response uint uint)

#### `get-total-supply()`
Returns current total supply of tokens.
- **Returns**: (response uint uint)

### Token Operations

#### `mint(amount, recipient)`
Mint new tokens to specified address.
- **Access**: Owner or authorized minter only
- **Parameters**: amount (uint), recipient (principal)
- **Restrictions**: Must not exceed supply cap, recipient not blacklisted

#### `burn(amount)`
Burn tokens from caller's balance.
- **Parameters**: amount (uint)
- **Restrictions**: Caller not blacklisted, sufficient balance

#### `transfer-two(recipient1, amount1, recipient2, amount2)`
Transfer to two recipients in one transaction.
- **Access**: Any token holder
- **Parameters**: Two recipient/amount pairs
- **Benefits**: Gas efficient bulk operation

#### `bulk-mint(amount1, recipient1, amount2, recipient2)`
Mint to two recipients simultaneously.
- **Access**: Owner or authorized minter only
- **Parameters**: Two amount/recipient pairs

### Administrative Functions

#### `add-minter(minter)` / `remove-minter(minter)`
Manage minter privileges.
- **Access**: Owner only
- **Parameters**: minter (principal)

#### `blacklist-user(user)` / `unblacklist-user(user)`
Manage blacklisted addresses.
- **Access**: Owner only
- **Parameters**: user (principal)

#### `pause-contract()` / `unpause-contract()`
Control contract operations.
- **Access**: Owner only

#### `emergency-pause()`
Emergency pause capability.
- **Access**: Owner or any minter

#### `transfer-ownership(new-owner)`
Transfer contract ownership.
- **Access**: Owner only
- **Parameters**: new-owner (principal)

### Read-Only Functions

#### `get-token-info()`
Returns comprehensive token information including name, symbol, supply, and status.

#### `get-remaining-cap()`
Returns remaining mintable tokens before hitting supply cap.

#### `check-minter(user)` / `check-blacklisted(user)`
Check user roles and status.

## Error Codes

- **u100**: Owner only operation
- **u101**: Insufficient balance  
- **u102**: Invalid amount (must be > 0)
- **u103**: Unauthorized operation
- **u104**: Supply cap exceeded
- **u107**: Contract paused

## Usage Examples

### Basic Transfer
```clarity
(contract-call? .capped-token transfer u1000000 tx-sender 'SP1234... none)
```

### Minting Tokens
```clarity
(contract-call? .capped-token mint u5000000 'SP1234...)
```

### Checking Balance
```clarity
(contract-call? .capped-token get-balance 'SP1234...)
```

### Bulk Operations
```clarity
(contract-call? .capped-token transfer-two 'SP1111... u1000000 'SP2222... u2000000)
```

## Security Considerations

1. **Supply Cap**: Prevents inflation beyond predetermined limit
2. **Access Control**: Multi-tier permission system
3. **Emergency Controls**: Pause mechanism for security incidents
4. **Blacklist Protection**: Prevents interaction with malicious addresses
5. **Input Validation**: All parameters validated before execution

## Deployment

The contract initializes with the deployer as the owner and first authorized minter. No initial token supply is minted - tokens must be explicitly minted after deployment.

