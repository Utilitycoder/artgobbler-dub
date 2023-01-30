# RandProvider
[Git Source](https://github.com/Utilitycoder/artgobbler-dub/blob/3c22f2fc754088c788fa1c2d53754e6ba88dfed3/src/utils/rand/RandProvider.sol)

**Author:**
lawal B.

generic asynchronous randomness provider interface


## Functions
### requestRandomBytes

*Request function bytes from the randomness provider*


```solidity
function requestRandomBytes() external returns (bytes32 requestId);
```

## Events
### RandomBytesRequested
EVENTS


```solidity
event RandomBytesRequested(bytes32 requestId);
```

### RandomBytesReturned

```solidity
event RandomBytesReturned(bytes32 returnId, uint256 randomness);
```

