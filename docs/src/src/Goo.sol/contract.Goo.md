# Goo
[Git Source](https://github.com/Utilitycoder/artgobbler-dub/blob/3c22f2fc754088c788fa1c2d53754e6ba88dfed3/src/Goo.sol)

**Inherits:**
ERC20

**Author:**
Lawal B.

Goo is the in-game token for ArtGobblers. It's a standard ERC20
token that can be burned ad minted by the gobblers and pages contract.


## State Variables
### artGobblers
The address of the Art Gobblers contract


```solidity
address public immutable artGobblers;
```


### pages
The address of the Pages contract.


```solidity
address public immutable pages;
```


## Functions
### constructor

Sets the address of relevant contracts.


```solidity
constructor(address _artGobblers, address _pages);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_artGobblers`|`address`|Address of the ArtGobblers contract|
|`_pages`|`address`|Address of the pages contract|


### only

MINT / BURN LOGIC


```solidity
modifier only(address user);
```

### mintForGobblers

Mint any amount of Goo to a user. Can only be called by ArtGobblers.


```solidity
function mintForGobblers(address to, uint256 amount) external only(artGobblers);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|The address of the recipient|
|`amount`|`uint256`|The amount of goo to be minted|


### burnForGobblers

Burn any amount of goo from a user. Can only be called by ArtGobblers


```solidity
function burnForGobblers(address from, uint256 amount) external only(artGobblers);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|the address of the user to burn goo from.`|
|`amount`|`uint256`|the amount of goo to burn|


### burnForPages

Burn any amount of goo from a user. Can only be called by pages


```solidity
function burnForPages(address from, uint256 amount) external only(pages);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|the address of the user to burn goo from|
|`amount`|`uint256`|the amount of goo to burn.|


## Errors
### Unathorized

```solidity
error Unathorized();
```

