// SPDX-License-Identifier: agpl-3.0

pragma solidity ^0.8.3;

import "./IExecutorWithTimelock.sol";

interface IExecutableGovernance {
    enum ProposalState {
        Pending,
        Active,
        Slashed,
        Voided,
        Passed,
        Failed,
        Queued,
        Expired,
        Executed
    }

    enum Support {
        agreeVotes,
        disagreeVotes,
        disagreeWithVetoVotes,
        abstentionVotes
    }

    struct Vote {
        Support support;
        uint248 votingPower;
    }

    struct Proposal {
        uint96 id;
        address creator;
        IExecutorWithTimelock executor;
        uint80 executionTime;
        bool executed;
        address strategy;
        uint48 startBlock;
        uint48 endBlock;
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        bool[] withDelegatecalls;
        uint256 agreeVotes;
        uint256 disagreeVotes;
        uint256 disagreeWithVetoVotes;
        uint256 abstentionVotes;
        uint256 votingTotalSupply;
        bytes32 ipfsHash;
        mapping(address => Vote) votes;
    }

    struct ProposalWithoutVotes {
        uint96 id;
        address creator;
        IExecutorWithTimelock executor;
        uint80 executionTime;
        bool executed;
        address strategy;
        uint48 startBlock;
        uint48 endBlock;
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        bool[] withDelegatecalls;
        uint256 agreeVotes;
        uint256 disagreeVotes;
        uint256 disagreeWithVetoVotes;
        uint256 abstentionVotes;
        uint256 votingTotalSupply;
        bytes32 ipfsHash;
    }

    /**
     * @dev emitted when a new proposal is created
     * @param id Id of the proposal
     * @param creator address of the creator
     * @param executor The ExecutorWithTimelock contract that will execute the proposal
     * @param targets list of contracts called by proposal's associated transactions
     * @param values list of value in wei for each propoposal's associated transaction
     * @param signatures list of function signatures (can be empty) to be used when created the callData
     * @param calldatas list of calldatas: if associated signature empty, calldata ready, else calldata is arguments
     * @param withDelegatecalls boolean, true = transaction delegatecalls the taget, else calls the target
     * @param startBlock block number when vote starts
     * @param endBlock block number when vote ends
     * @param strategy address of the governanceStrategy contract
     * @param ipfsHash IPFS hash of the proposal
     **/
    event ProposalCreated(
        uint256 id,
        address indexed creator,
        IExecutorWithTimelock indexed executor,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        bool[] withDelegatecalls,
        uint256 startBlock,
        uint256 endBlock,
        address strategy,
        bytes32 ipfsHash
    );

    /**
     * @dev emitted when a proposal is queued
     * @param id Id of the proposal
     * @param executionTime time when proposal underlying transactions can be executed
     * @param initiatorQueueing address of the initiator of the queuing transaction
     **/
    event ProposalQueued(
        uint256 id,
        uint256 executionTime,
        address indexed initiatorQueueing
    );

    /**
     * @dev emitted when a proposal is slashed
     * @param id Id of the proposal
     * @param initiatorQueueing address of the initiator of the queuing transaction
     **/
    event ProposalSlashed(uint256 id, address indexed initiatorQueueing);

    /**
     * @dev emitted when a proposal is executed
     * @param id Id of the proposal
     * @param initiatorExecution address of the initiator of the execution transaction
     **/
    event ProposalExecuted(uint256 id, address indexed initiatorExecution);
    /**
     * @dev emitted when a vote is registered
     * @param id Id of the proposal
     * @param voter address of the voter
     * @param support boolean, true = vote for, false = vote against
     * @param votingPower Power of the voter/vote
     * @param votingMaxPower Maximum Power of the voter/vote
     **/
    event VoteEmitted(
        uint256 id,
        address indexed voter,
        Support support,
        uint256 votingPower,
        uint256 votingMaxPower
    );

    event GovernanceStrategyChanged(
        address indexed newStrategy,
        address indexed initiatorChange
    );

    event VotingDelayChanged(
        uint256 newVotingDelay,
        address indexed initiatorChange
    );

    event ExecutorAuthorized(address executor);

    event ExecutorUnauthorized(address executor);

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

    /**
     * @dev Queue the proposal (If Proposal Succeeded)
     * @param proposalId id of the proposal to queue
     **/
    function queue(uint96 proposalId) external;

    /**
     * @dev Execute the proposal (If Proposal Queued)
     * @param proposalId id of the proposal to execute
     **/
    function execute(uint96 proposalId) external payable;

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

    /**
     * @dev Set new GovernanceStrategy
     * Note: owner should be a timelocked executor, so needs to make a proposal
     * @param governanceStrategy new Address of the GovernanceStrategy contract
     **/
    function setGovernanceStrategy(address governanceStrategy) external;

    /**
     * @dev Set new Voting Delay (delay before a newly created proposal can be voted on)
     * Note: owner should be a timelocked executor, so needs to make a proposal
     * @param votingDelay new voting delay in seconds
     **/
    function setVotingDelay(uint48 votingDelay) external;

    /**
     * @dev Add new addresses to the list of authorized executors
     * @param executors list of new addresses to be authorized executors
     **/
    function authorizeExecutors(address[] memory executors) external;

    /**
     * @dev Remove addresses to the list of authorized executors
     * @param executors list of addresses to be removed as authorized executors
     **/
    function unauthorizeExecutors(address[] memory executors) external;

    /**
     * @dev Let the guardian abdicate from its priviledged rights
     **/
    function __abdicate() external;

    /**
     * @dev Getter of the current GovernanceStrategy address
     * @return The address of the current GovernanceStrategy contracts
     **/
    function getGovernanceStrategy() external view returns (address);

    /**
     * @dev Getter of the current Voting Delay (delay before a created proposal can be voted on)
     * Different from the voting duration
     * @return The voting delay in seconds
     **/
    function getVotingDelay() external view returns (uint256);

    /**
     * @dev Returns whether an address is an authorized executor
     * @param executor address to evaluate as authorized executor
     * @return true if authorized
     **/
    function isExecutorAuthorized(address executor)
        external
        view
        returns (bool);

    /**
     * @dev Getter the address of the guardian, that can mainly cancel proposals
     * @return The address of the guardian
     **/
    function getGuardian() external view returns (address);

    /**
     * @dev Getter of the proposal count (the current number of proposals ever created)
     * @return the proposal count
     **/
    function getProposalsCount() external view returns (uint256);

    /**
     * @dev Getter of a proposal by id
     * @param proposalId id of the proposal to get
     * @return the proposal as ProposalWithoutVotes memory object
     **/
    function getProposalById(uint96 proposalId)
        external
        view
        returns (ProposalWithoutVotes memory);

    /**
     * @dev Getter of the Vote of a voter about a proposal
     * Note: Vote is a struct: ({bool support, uint248 votingPower})
     * @param proposalId id of the proposal
     * @param voter address of the voter
     * @return The associated Vote memory object
     **/
    function getVoteOnProposal(uint96 proposalId, address voter)
        external
        view
        returns (Vote memory);

    /**
     * @dev Get the current state of a proposal
     * @param proposalId id of the proposal
     * @return The current state if the proposal
     **/
    function getProposalState(uint96 proposalId)
        external
        view
        returns (ProposalState);

    function getUserVote(uint96 proposalId, address voter)
        external
        view
        returns (uint8, uint248);
}
