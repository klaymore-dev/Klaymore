// SPDX-License-Identifier: agpl-3.0

pragma solidity ^0.8.3;

import "./IExecutableGovernance.sol";

interface IProposalValidator {
    /**
     * @dev Called to validate a proposal (e.g when creating new proposal in Governance)
     * @param governance Governance Contract
     * @param user Address of the proposal creator
     * @param governanceToken Address of the governanceToken
     * @return boolean, true if can be created
     **/
    function validateCreatorOfProposal(
        IExecutableGovernance governance,
        address user,
        address governanceToken
    ) external view returns (bool);

    /**
     * @dev Returns whether a user has enough Proposition Power to make a proposal.
     * @param governance Governance Contract
     * @param user Address of the user to be challenged.
     * @param governanceToken Address of the governanceToken
     * @return true if user has enough power
     **/
    function isPropositionPowerEnough(
        IExecutableGovernance governance,
        address user,
        address governanceToken
    ) external view returns (bool);

    /**
     * @dev Returns whether a proposal passed or not
     * @param governance Governance Contract
     * @param proposalId Id of the proposal to set
     * @return true if proposal passed
     **/
    function isProposalPassed(
        IExecutableGovernance governance,
        uint96 proposalId
    ) external view returns (bool);

    function isProposalSlashed(
        IExecutableGovernance governance,
        uint96 proposalId
    ) external view returns (bool);

    /**
     * @dev Check whether a proposal has reached quorum, ie has enough FOR-voting-power
     * Here quorum is not to understand as number of votes reached, but number of for-votes reached
     * @param governance Governance Contract
     * @return voting power needed for a proposal to pass
     **/
    function isQuorumValid(IExecutableGovernance governance, uint96 proposalId)
        external
        view
        returns (bool);

    /**
     * @dev Calculates the minimum amount of Voting Power needed for a proposal to Pass
     * @param votingSupply Total number of oustanding voting tokens
     * @return voting power needed for a proposal to pass
     **/
    function getMinimumVotingPowerNeeded(uint256 votingSupply)
        external
        view
        returns (uint256);

    /**
     * @dev Get voting duration constant value
     * @return the voting duration value in seconds
     **/
    function votingDuration() external view returns (uint256);

    /**
     * @dev Get quorum threshold constant value
     * to compare with % of for votes/total supply
     * @return the quorum threshold value (100 <=> 1%)
     **/
    function minimumQuorum() external view returns (uint256);

    function minimumPropositionPower() external view returns (uint256);

    function downPayment() external view returns (uint256);

    /**
     * @dev precision helper: 100% = 10000
     * @return one hundred percents with our chosen precision
     **/
    function ONE_HUNDRED_WITH_PRECISION() external view returns (uint256);
}
