# GobblerReserve
[Git Source](https://github.com/Utilitycoder/artgobbler-dub/blob/3c22f2fc754088c788fa1c2d53754e6ba88dfed3/src/utils/GobblerReserve.sol)

**Inherits:**
Owned

**Authors:**
FrankieIsLost <frankie@paradigm.xyz>, transmissions11 <t11s@paradigm.xyz>

Reserves gobblers for an owner while keeping any goo produced.


## State Variables
### artGobblers
Art Gobblers contract address.


```solidity
ArtGobblers public immutable artGobblers;
```


## Functions
### constructor

Sets the addresses of relevant contracts and users.


```solidity
constructor(ArtGobblers _artGobblers, address _owner) Owned(_owner);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_artGobblers`|`ArtGobblers`|The address of the ArtGobblers contract.|
|`_owner`|`address`|The address of the owner of Gobbler Reserve.|


### withdraw

Withdraw gobblers from the reserve.


```solidity
function withdraw(address to, uint256[] calldata ids) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|The address to transfer the gobblers to.|
|`ids`|`uint256[]`|The ids of the gobblers to transfer.|


