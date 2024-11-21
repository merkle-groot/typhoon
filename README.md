# Typhoon

A coin-mixer project inspired by [Tornado Cash](https://github.com/tornadocash/tornado-core) and [Miksi](https://github.com/arnaucube/miksi-core)

## Compiling circuits
1. Compile Deposit circuit
```
circom ./circuits/deposit.circom
```

2. Compile Withdraw circuit
```
circom ./circuits/withdraw.circom
```

## Compiling contracts
1. Compile all the contracts
```
npx hardhat compile
```