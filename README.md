# polatine-smart-contracts

## How to use
1. Open Remix IDE
2. Select Solidity
3. Create new file in folder contracts
4. Paste the contents of nft-boilerplate.sol
5. Save



# Optimization test

2022-04-17
Tried creating subcollection as a struct thus only two mappings: tokenid to subcollection, and address to subcollection. This proved to have a slightly higher deployment cost. Might be worth keeping just because the code is cleaner.
