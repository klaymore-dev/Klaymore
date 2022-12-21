// SPDX-License-Identifier: agpl-3.0

pragma solidity ^0.8.3;

/**
 * @title Governance Strategy contract
 * @dev Smart contract containing logic to measure users' relative power to propose and vote.
 * Two wrapper functions linked to KLAYMORE Tokens's GovernancePowerDelegationERC20.sol implementation
 * - getPropositionPowerAt: fetching a user Proposition Power at a specified block
 * - getVotingPowerAt: fetching a user Voting Power at a specified block
 * @author KLAYMORE
 **/
interface IGovernanceStrategy {
    /**
     * @dev Returns the Maximum Vote Power.
     * @return Vote number
     **/
    function getMaxVotingPower() external view returns (uint256);

    /**
     * @dev Returns the Maximum Vote Power of a user.
     * @param user Address of the user.
     * @return Vote number
     **/
    function getUserMaxVotingPower(address user)
        external
        view
        returns (uint256);

    function onVote(address user, uint256 endBlock) external;

    function unstakeLockEndAtBlock(address user)
        external
        view
        returns (uint256);
}
