# CounterV2 Deployment Steps

## Step 1: Create The Account Entry

```bash
sncast account create --name Yusrah --network sepolia
```

Save the generated account address and fund it with Sepolia tokens for fees.

## Step 2: Deploy The Account

```bash
sncast account deploy --name Yusrah --network sepolia
```

## Step 3: List Accounts

```bash
sncast account list
```

Save the address for the `Yusrah` account.

Yusrah's acc. address 0x72658e0505e77137829e255912c52f8ca0ae73de5dde8332686b1adac3034f0

## Step 4: Go Into The Contract Package

```bash
cd ~/Desktop/cairo-begining/cairo-bootcamp-6/starknet_contracts
```

## Step 5: Build The Contract

```bash
scarb build
```

## Step 6: Declare CounterV2

```bash
sncast --account Yusrah \
  declare \
  --contract-name CounterV2 \
  --network sepolia \
  --wait
```

Save the `class_hash` from the output.

class harsh  0x1e3a5b348490a07cea9f2788b81e46132c107724621e462494a5d20b67d458d

## Step 7: Deploy CounterV2

Replace:

- `PASTE_CLASS_HASH_HERE`
- `PASTE_YUSRAH_ADDRESS_HERE`

```bash
sncast --account Yusrah \
  deploy \
  --class-hash PASTE_CLASS_HASH_HERE \
  --constructor-calldata PASTE_YUSRAH_ADDRESS_HERE \
  --network sepolia \
  --wait
```

Save the deployed `contract_address`.

contract address 0x031e9847e60b0e7224c095cd45e260aa96daa0cec22960a8ab1cc51949997f36

## Step 8: Verify The Owner

Replace `PASTE_CONTRACT_ADDRESS_HERE`.

```bash
sncast call \
  --contract-address PASTE_CONTRACT_ADDRESS_HERE \
  --function get_owner \
  --network sepolia
```

## Step 9: Verify The Initial Count

```bash
sncast call \
  --contract-address PASTE_CONTRACT_ADDRESS_HERE \
  --function get_count \
  --network sepolia
```

Expected:

```text
0
```

## Step 10: Increase The Count By 10

```bash
sncast --account Yusrah \
  invoke \
  --contract-address PASTE_CONTRACT_ADDRESS_HERE \
  --function increase_count \
  --calldata 10 \
  --network sepolia \
  --wait
```

## Step 11: Verify The Count After Increasing

```bash
sncast call \
  --contract-address PASTE_CONTRACT_ADDRESS_HERE \
  --function get_count \
  --network sepolia
```

Expected:

```text
10
```

## Step 12: Reduce The Count By 4

```bash
sncast --account Yusrah \
  invoke \
  --contract-address PASTE_CONTRACT_ADDRESS_HERE \
  --function reduce_count \
  --calldata 4 \
  --network sepolia \
  --wait
```

## Step 13: Verify The Count After Reducing

```bash
sncast call \
  --contract-address PASTE_CONTRACT_ADDRESS_HERE \
  --function get_count \
  --network sepolia
```

Expected:

```text
6
```

## Step 14: Demo Subtraction Underflow Protection

```bash
sncast --account Yusrah \
  invoke \
  --contract-address PASTE_CONTRACT_ADDRESS_HERE \
  --function reduce_count \
  --calldata 200 \
  --network sepolia \
  --wait
```

Expected:

An error because the subtraction underflows.

## Step 15: Demo Non-Owner Rejection

Replace `OTHER_ACCOUNT_NAME`.

```bash
sncast --account OTHER_ACCOUNT_NAME \
  invoke \
  --contract-address PASTE_CONTRACT_ADDRESS_HERE \
  --function increase_count \
  --calldata 1 \
  --network sepolia \
  --wait
```

Expected:

An error because the caller is not the owner.


e.g of non owner address 0x00A879C0fEf9C803041Ab7524859879B5d68684f413890401566367ae38a3a10