# PagesERC721
[Git Source](https://github.com/Utilitycoder/artgobbler-dub/blob/3c22f2fc754088c788fa1c2d53754e6ba88dfed3/src/utils/token/PagesERC721.sol)

**Author:**
Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)

ERC721 implementation optimized for Pages by pre-approving them to the ArtGobblers contract.


## State Variables
### name

```solidity
string public name;
```


### symbol

```solidity
string public symbol;
```


### artGobblers

```solidity
ArtGobblers public immutable artGobblers;
```


### _ownerOf

```solidity
mapping(uint256 => address) internal _ownerOf;
```


### _balanceOf

```solidity
mapping(address => uint256) internal _balanceOf;
```


### getApproved

```solidity
mapping(uint256 => address) public getApproved;
```


### _isApprovedForAll

```solidity
mapping(address => mapping(address => bool)) internal _isApprovedForAll;
```


## Functions
### tokenURI


```solidity
function tokenURI(uint256 id) external view virtual returns (string memory);
```

### constructor


```solidity
constructor(ArtGobblers _artGobblers, string memory _name, string memory _symbol);
```

### ownerOf


```solidity
function ownerOf(uint256 id) external view returns (address owner);
```

### balanceOf


```solidity
function balanceOf(address owner) external view returns (uint256);
```

### isApprovedForAll


```solidity
function isApprovedForAll(address owner, address operator) public view returns (bool isApproved);
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
function transferFrom(address from, address to, uint256 id) public;
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

