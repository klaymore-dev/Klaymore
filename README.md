# Klaymore executable governance interfaces

- Minimum staking amount to create a proposal: 10,000,000 HOUSE
- 1,000,000 HOUSE slashing when finished with veto (You must have 1,000,000 HOUSE.)

## Support Options

0. agree
1. disagree
2. disagree with veto
3. abstain

## Proposal state condition

The proposal will be in the pending state for 3 days. After that, it will change to the active state and you will be able to vote for 7 days.
At the end of the voting period, proposals are classified into three states: **Void, Pass, or Slashing**.

In the case of slashing, the deposited 1,000,000 HOUSE is burned.
If it is a pass, you run the queue function to get ready to run the transaction, and execute it via the execute function. At this time, if it is queued and not executed for 10 days, the transaction expires.
When you run the queue function, the 1,000,000 HOUSE you deposited is refunded.

- Void : `agree + disagree + abstain < Quorum`
- Pass : `agree > disagree + disagree with veto`
- Slashing : `disagree with veto > agree + disagree + abstain`
- else Fail

## Constants Spec

|                         |                remarks                 |      value       |
| :---------------------: | :------------------------------------: | :--------------: |
|         Quraom          |                 Quraom                 |       20 %       |
|       votingDelay       |     From Proposal Create to Voting     |      3 days      |
|     votingDuration      |             voting period              |      7 days      |
|       gracePeriod       |        time to expire in queue         |     10 days      |
|          delay          | Buffer until voting ends and execution |      60 sec      |
| minimumPropositionPower |  Minimum SHOUSE to create a proposal   | 10,000,000 HOUSE |
|       downPayment       |       Deposit to prevent abusing       | 1,000,000 HOUSE  |

## Usage

Function interfaces are almost the same as those in [aave-v2 governance](https://github.com/aave/governance-v2).

### 1. Create proposal

```solidity
/**
 * @dev Creates a Proposal (needs Proposition Power of creator > Threshold)
 * @param executor The ExecutorWithTimelock contract that will execute the proposal
 * @param targets list of contracts called by proposal's associated transactions
 * @param values list of value in wei for each propoposal's associated transaction
 * @param signatures list of function signatures (can be empty) to be used when created the callData
 * @param calldatas list of calldatas: if associated signature empty, calldata ready, else calldata is arguments
 * @param withDelegatecalls if true, transaction delegatecalls the taget, else calls the target
 * @param ipfsHash IPFS hash of the proposal
 **/
function create(
  IExecutorWithTimelock executor,
  address[] memory targets,
  uint256[] memory values,
  string[] memory signatures,
  bytes[] memory calldatas,
  bool[] memory withDelegatecalls,
  bytes32 ipfsHash
) external returns (uint256);

```

example:

```typescript
const gov = await ethers.getContract("HouseGovernanceV2");
const executor = await ethers.getContract("Executor");
const ipfsBytes32Hash =
  "0x47858569385046d7f77f5032ae41e511b40a7fbfbd315503ba3d99a6dc885f2b";
const callData = await gov.interface.encodeFunctionData("setVotingDelay", [
  BigNumber.from("400"),
]);

//Creating first proposal: Changing delay to 300 via no sig + calldata
const tx = await gov.create(
  executor.address,
  [gov.address],
  ["0"],
  [""],
  [callData],
  [false],
  ipfsBytes32Hash
);
await tx.wait();
```

### 2. Vote proposal

```solidity
/**
 * @dev Function allowing msg.sender to vote for/against a proposal
 * @param proposalId id of the proposal
 * @param votingPower amount of vote
 * @param support uint96, 0 = `agreeVotes`, 1 = `disagreeVotes`, 2 = `disagreeWithVetoVotes`, 3 = `abstentionVotes`
 **/
function submitVote(
  uint96 proposalId,
  Support support,
  uint256 votingPower
) external;

```

example:

```typescript
const gov = await ethers.getContract("HouseGovernanceV2");

const tx = await gov.submitVote(1, 0, BigNumber.from("1000000000000000"));
await tx.wait();
```

### 3. Queue proposal if succeed

```solidity
/**
 * @dev Queue the proposal (If Proposal Succeeded)
 * @param proposalId id of the proposal to queue
 **/
function queue(uint96 proposalId) external;

```

example:

```typescript
const gov = await ethers.getContract("HouseGovernanceV2");

const tx = await gov.queue(1);
await tx.wait();
```

### 4. Execute proposal if succeed

```solidity
/**
 * @dev Execute the proposal (If Proposal Queued)
 * @param proposalId id of the proposal to execute
 **/
function execute(uint96 proposalId) external payable;

```

example:

```typescript
const gov = await ethers.getContract("HouseGovernanceV2");

const tx = await gov.execute(1);
await tx.wait();
```

## Contract addesses

TBD
