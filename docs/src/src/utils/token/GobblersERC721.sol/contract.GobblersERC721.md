# GobblersERC721
[Git Source](https://github.com/Utilitycoder/artgobbler-dub/blob/3c22f2fc754088c788fa1c2d53754e6ba88dfed3/src/utils/token/GobblersERC721.sol)

**Author:**
Modified from solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)

ERC721 implementation optimized for ArtGobblers by packing balanceOf/ownerOf with user/attribute data.


## State Variables
### name

```solidity
string public name;
```


### symbol

```solidity
string public symbol;
```


### getGobblerData
Maps gobbler ids to their data.


```solidity
mapping(uint256 => GobblerData) public getGobblerData;
```


### getUserData
Maps user addresses to their account data.


```solidity
mapping(address => UserData) public getUserData;
```


### getApproved

```solidity
mapping(uint256 => address) public getApproved;
```


### isApprovedForAll

```solidity
mapping(address => mapping(address => bool)) public isApprovedForAll;
```


## Functions
### tokenURI


```solidity
function tokenURI(uint256 id) external view virtual returns (string memory);
```

### ownerOf


```solidity
function ownerOf(uint256 id) external view returns (address owner);
```

### balanceOf


```solidity
function balanceOf(address owner) external view returns (uint256);
```

### constructor


```solidity
constructor(string memory _name, string memory _symbol);
```

### approve


```solidity
function approve(address spender, uint256 id) external;
```

### setApprovalForAll


```solidity
function setApprovalForAll(address operator, bool approved) external;
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 id) public virtual;
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 id) external;
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) external;
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) external pure returns (bool);
```

### _mint


```solidity
function _mint(address to, uint256 id) internal;
```

### _batchMint


```solidity
function _batchMint(address to, uint256 amount, uint256 lastMintedId) internal returns (uint256);
```

## Events
### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed id);
```

### Approval

```solidity
event Approval(address indexed owner, address indexed spender, uint256 indexed id);
```

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
```

## Structs
### GobblerData
Struct holding gobbler data.


```solidity
struct GobblerData {
    address owner;
    uint64 idx;
    uint32 emissionMultiple;
}
```

### UserData
Struct holding data relevant to each user's account.


```solidity
struct UserData {
    uint32 gobblersOwned;
    uint32 emissionMultiple;
    uint128 lastBalance;
    uint64 lastTimestamp;
}
```

