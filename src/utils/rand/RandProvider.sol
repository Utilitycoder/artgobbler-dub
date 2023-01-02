// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

///@title Randomness Provider Interface.
/// @author lawal B.
///@notice generic asynchronous randomness provider interface
interface RandProvider {
    /// EVENTS
    event RandomBytesRequested(bytes32 requestId);
    event RandomBytesReturned(bytes32 returnId, uint256 randomness);

    /// @dev Request function bytes from the randomness provider
    function requestRandomBytes() external returns (bytes32 requestId);
}
