# ChainlinkV1RandProvider
[Git Source](https://github.com/Utilitycoder/artgobbler-dub/blob/3c22f2fc754088c788fa1c2d53754e6ba88dfed3/src/utils/rand/ChainlinkV1RandProvider.sol)

**Inherits:**
[RandProvider](/src/utils/rand/RandProvider.sol/contract.RandProvider.md), VRFConsumerBase

**Author:**
Lawal

RandProvider wrapper around chainlink VRF V1.


## State Variables
### artGobblers
address of the Art Gobbler contract


```solidity
ArtGobblers public immutable artGobblers;
```


### chainlinkKeyHash
*Public key to generate the randomness against*


```solidity
bytes32 internal immutable chainlinkKeyHash;
```


### chainlinkFee
*Fee required to fulfill a VRF request*


```solidity
uint256 internal immutable chainlinkFee;
```


## Functions
### constructor

Sets relevant addresses and VRF parameters.


```solidity
constructor(
    ArtGobblers _artGobblers,
    address _vrfCoordinator,
    address _linkToken,
    bytes32 _chainlinkKeyHash,
    uint256 _chainlinkFee
) VRFConsumerBase(_vrfCoordinator, _linkToken);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_artGobblers`|`ArtGobblers`|Address of the Art Gobblers comntract|
|`_vrfCoordinator`|`address`|Address of the VRF coordinator|
|`_linkToken`|`address`|Address of the link token contract|
|`_chainlinkKeyHash`|`bytes32`|Public key to generate randomness against|
|`_chainlinkFee`|`uint256`|Fee required to fulfill a VRF request|


### requestRandomBytes

Request random bytes from chainlink VRF. It can only be called by ArtGobblers contract.


```solidity
function requestRandomBytes() external returns (bytes32 requestId);
```

### fulfillRandomness

Revert if caller is not the artGobblers contract

*Handle VRF response by calling back into the ArtGobblers contract.*


```solidity
function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override;
```

## Errors
### NotGobblers

```solidity
error NotGobblers();
```

