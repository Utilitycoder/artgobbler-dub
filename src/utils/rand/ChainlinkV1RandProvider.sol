// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {VRFConsumerBase} from "chainlink/v0.8/VRFConsumerBase.sol";

import {ArtGobblers} from "../../ArtGobblers.sol";

import {RandProvider} from "./RandProvider.sol";

/// @title chainlink randomness provider contract
/// @author Lawal
/// @notice  RandProvider wrapper around chainlink VRF V1.
contract ChainlinkV1RandProvider is RandProvider, VRFConsumerBase {
    /// @notice address of the Art Gobbler contract
    ArtGobblers public immutable artGobblers;

    /// @dev Public key to generate the randomness against
    bytes32 internal immutable chainlinkKeyHash;

    /// @dev Fee required to fulfill a VRF request
    uint256 internal immutable chainlinkFee;

    error NotGobblers();

    /// @notice Sets relevant addresses and VRF parameters.
    /// @param _artGobblers Address of the Art Gobblers comntract
    /// @param _vrfCoordinator Address of the VRF coordinator
    /// @param _linkToken Address of the link token contract
    /// @param _chainlinkKeyHash Public key to generate randomness against
    /// @param _chainlinkFee Fee required to fulfill a VRF request
    constructor(
        ArtGobblers _artGobblers,
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _chainlinkKeyHash,
        uint256 _chainlinkFee
    ) VRFConsumerBase(_vrfCoordinator, _linkToken) {
        artGobblers = _artGobblers;
        chainlinkKeyHash = _chainlinkKeyHash;
        chainlinkFee = _chainlinkFee;
    }

    /// @notice Request random bytes from chainlink VRF. It can only be called by ArtGobblers contract.
    function requestRandomBytes() external returns (bytes32 requestId) {
        /// Revert if caller is not the artGobblers contract
        if(msg.sender != address(artGobblers)) revert NotGobblers();

        emit RandomBytesRequested(requestId =requestRandomness(chainlinkKeyHash, chainlinkFee));
    }

    /// @dev Handle VRF response by calling back into the ArtGobblers contract.
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        emit RandomBytesReturned(requestId, randomness);
        artGobblers.acceptRandomSeed(requestId, randomness);
    }
}
