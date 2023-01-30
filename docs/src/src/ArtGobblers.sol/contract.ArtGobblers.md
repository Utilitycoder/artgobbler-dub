# ArtGobblers
[Git Source](https://github.com/Utilitycoder/artgobbler-dub/blob/3c22f2fc754088c788fa1c2d53754e6ba88dfed3/src/ArtGobblers.sol)

**Inherits:**
[GobblersERC721](/src/utils/token/GobblersERC721.sol/contract.GobblersERC721.md), LogisticVRGDA, Owned, ERC1155TokenReceiver


## State Variables
### goo
ADDRESSES

The address of the Goo ERC20 token contract.


```solidity
Goo public immutable goo;
```


### pages
the address of the Pages ERC721 token contract.


```solidity
Pages public immutable pages;
```


### team
The address which receives gobblers reserved for the team.


```solidity
address public immutable team;
```


### community
The address which receives gobblers reserved for the community.


```solidity
address public immutable community;
```


### randProvider
The address of a randomness provider. This provider will initially be a wrapper around chainlink VRF v1, but can be changed in case it is fully sunset.


```solidity
RandProvider public randProvider;
```


### MAX_SUPPLY
Maximum number of mintable gobblers.


```solidity
uint256 public constant MAX_SUPPLY = 10000;
```


### MINTLIST_SUPPLY
Maximum amount of gobblers mintable via mintlist.


```solidity
uint256 public constant MINTLIST_SUPPLY = 2000;
```


### LEGENDARY_SUPPLY
Maximum amount of mintable legendary gobblers.


```solidity
uint256 public constant LEGENDARY_SUPPLY = 10;
```


### RESERVED_SUPPLY
Maximum amount of gobblers split between the reserves.

*Set to comprise 20% of the sum of goo mintable gobblers + reserved gobblers.*


```solidity
uint256 public constant RESERVED_SUPPLY = (MAX_SUPPLY - MINTLIST_SUPPLY - LEGENDARY_SUPPLY) / 5;
```


### MAX_MINTABLE
Maximum amount of gobblers that can be minted via VRGDA.


```solidity
uint256 public constant MAX_MINTABLE = MAX_SUPPLY - MINTLIST_SUPPLY - LEGENDARY_SUPPLY - RESERVED_SUPPLY;
```


### PROVENANCE_HASH
METADATA CONSTANTS

Provenance hash for gobblers metadata.


```solidity
bytes32 public immutable PROVENANCE_HASH;
```


### UNREVEALED_URI
URI for gobblers pending reveal


```solidity
string public UNREVEALED_URI;
```


### BASE_URI
Base URI for minted gobblers.


```solidity
string public BASE_URI;
```


### merkleRoot
Merkle root of mint mintlist.


```solidity
bytes32 public immutable merkleRoot;
```


### hasClaimedMintlistGobbler
Mapping to keep track of which addresses have claimed from mintlist.


```solidity
mapping(address => bool) hasClaimedMintlistGobbler;
```


### mintStart
Timestamp for the start of minting.


```solidity
uint256 public immutable mintStart;
```


### numMintedFromGoo
Number of gobblers minted from goo.


```solidity
uint128 public numMintedFromGoo;
```


### currentNonLegendaryId
STANDARD GOBBLER STATE

Id of the most recently minted non-legendary gobbler.

*Will be 0 if no non legendary gobblers have been minted yet.*


```solidity
uint256 public currentNonLegendaryId;
```


### numMintedForReserves
The number of gobblers minted to the reserves.


```solidity
uint256 public numMintedForReserves;
```


### LEGENDARY_GOBBLER_INITIAL_START_PRICE
Initial legendary gobbler auction price.


```solidity
uint256 public constant LEGENDARY_GOBBLER_INITIAL_START_PRICE = 69;
```


### FIRST_LEGENDARY_GOBBLER_ID
The last LEGENDARY_SUPPLY ids are reserved for legendary gobblers.


```solidity
uint256 public constant FIRST_LEGENDARY_GOBBLER_ID = MAX_SUPPLY - LEGENDARY_SUPPLY + 1;
```


### LEGENDARY_AUCTION_INTERVAL
Legendary auctions begin each time a multiple of these many gobblers have been minted from goo.

*We add 1 to LEGENDARY_SUPPLY because legendary auctions being only after the first interval.*


```solidity
uint256 public constant LEGENDARY_AUCTION_INTERVAL = MAX_MINTABLE / (LEGENDARY_SUPPLY + 1);
```


### legendaryGobblerAuctionData
Data about the current legendary gobbler auction.


```solidity
LegendaryGobblerAuctionData public legendaryGobblerAuctionData;
```


### gobblerRevealsData
Data about the current state of goobler reveal


```solidity
GobblerRevealsData public gobblerRevealsData;
```


### getCopiesOfArtGobbledByGobbler
GOBBLED ART STATE

Maps gobbler ids to NFT contracts and their ids to the # of those NFT ids gobbled by the gobbler.


```solidity
mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public getCopiesOfArtGobbledByGobbler;
```


## Functions
### constructor

CONSTRUCTOR ///

Sets VRGDA parameters, mint config, relevant address and URIs.


```solidity
constructor(
    bytes32 _merkleRoot,
    uint256 _mintStart,
    Goo _goo,
    Pages _pages,
    address _team,
    address _community,
    RandProvider _randProvider,
    string memory _baseUri,
    string memory _unrevealedUri,
    bytes32 _provenanceHash
)
    GobblersERC721("Art Gobblers", "GOBBLER")
    Owned(msg.sender)
    LogisticVRGDA(69.42e18, 0.31e18, toWadUnsafe(MAX_MINTABLE), 0.0023e18);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_merkleRoot`|`bytes32`|Merkle root of mint mintlist|
|`_mintStart`|`uint256`|Timestamp for the start of the VRGDA mint.|
|`_goo`|`Goo`|Address of the Goo contract|
|`_pages`|`Pages`||
|`_team`|`address`|Address of the team reserve.|
|`_community`|`address`|Address of the community reserve.|
|`_randProvider`|`RandProvider`|Address of the randomness provider.|
|`_baseUri`|`string`|Base URI for the revealed gobblers.|
|`_unrevealedUri`|`string`|URI for the unrevealed gobblers.|
|`_provenanceHash`|`bytes32`|Provenance hash for gobbler metadata.|


### claimGobbler

Claim from mintlist using a merkle proof.

*Function does not directly enforce the MINTLIST_SUPPLY limit for gas efficiency. The limit is enforced
during the creation of the merkle proof, which will be shared publicly.*


```solidity
function claimGobbler(bytes32[] calldata proof) external returns (uint256 gobblerId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proof`|`bytes32[]`|Merkle proof to verify the sender is mintlisted|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`gobblerId`|`uint256`|The id of the gobbler that was claimed.|


### mintFromGoo

Mint a goobler paying with goo.


```solidity
function mintFromGoo(uint256 maxPrice, bool useVirtualBalance) external returns (uint256 gobblerId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxPrice`|`uint256`|Maximum price to pay to mint the gobbler.|
|`useVirtualBalance`|`bool`|Whether the cost is paid from the user's virtual goo balance, or from their ERC20 balance.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`gobblerId`|`uint256`|The id of the gobbler that was minted.|


### gobblerPrice

Gobbler pricing in terms of goo.

*Will revert if called before minting starts or after all gobbblers have been minted via VRGDA.*


```solidity
function gobblerPrice() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Current price of a gobbler in terms of goo.|


### mintLegendaryGobbler

Mint a legendary gobbler by burning multiple standard gobblers.


```solidity
function mintLegendaryGobbler(uint256[] calldata gobblerIds) external returns (uint256 gobblerId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gobblerIds`|`uint256[]`|The ids of the standard gobblers to burn.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`gobblerId`|`uint256`|The id of the legendary gobbler that was minted.|


### legendaryGobblerPrice

Calculate the legendary gobbler price in terms of gobblers, according to a linear decay function.

*The price of a legendary gobbler decays as gobblers are minted. The first legendary auction begins when
1 LEGENDARY_AUCTION_INTERVAL worth of gobblers are minted, and the price decays linearly while the next interval of
gobblers are minted. Every time an additional interval is minted, a new auction begins until all legendaries have been sold.*

*Will revert if the auction hasn't started yet or legendaries have sold out entirely.*


```solidity
function legendaryGobblerPrice() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The current price of the legendary gobbler being auctioned, in terms of gobblers.|


### requestRandomSeed

Request a new random seed for revealing gobblers.


```solidity
function requestRandomSeed() external returns (bytes32);
```

### acceptRandomSeed

Callback from rand provider. Sets randomSeed. Can only be called by the rand provider.


```solidity
function acceptRandomSeed(bytes32, uint256 randomness) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`||
|`randomness`|`uint256`|The 256 bits of verifiable randomness provided by the rand provider.|


### upgradeRandProvider

Upgrade the rand provider contract. Useful if current VRF is sunset.


```solidity
function upgradeRandProvider(RandProvider newRandProvider) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newRandProvider`|`RandProvider`|The new randomness provider contract address.|


### revealGobblers

Knuth shuffle to progressively reveal
new gobblers using entropy from a random seed.


```solidity
function revealGobblers(uint256 numGobblers) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`numGobblers`|`uint256`|The number of gobblers to reveal.|


### tokenURI

Returns a token's URI if it has been minted.


```solidity
function tokenURI(uint256 gobblerId) public view virtual override returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gobblerId`|`uint256`|The id of the token to get the URI for.|


### gobble

Feed a gobbler a work of art.


```solidity
function gobble(uint256 gobblerId, address nft, uint256 id, bool isERC1155) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gobblerId`|`uint256`|The gobbler to feed the work of art.|
|`nft`|`address`|The ERC721 or ERC1155 contract of the work of art.|
|`id`|`uint256`|The id of the work of art.|
|`isERC1155`|`bool`|Whether the work of art is an ERC1155 token.|


### gooBalance

Calculate a user's virtual goo balance.


```solidity
function gooBalance(address user) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The user to query balance for.|


### addGoo

Add goo to your emission balance,
burning the corresponding ERC20 balance.


```solidity
function addGoo(uint256 gooAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gooAmount`|`uint256`|The amount of goo to add.|


### removeGoo

Remove goo from your emission balance, and
add the corresponding amount to your ERC20 balance.


```solidity
function removeGoo(uint256 gooAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gooAmount`|`uint256`|The amount of goo to remove.|


### burnGooForPages

Burn an amount of a user's virtual goo balance. Only callable
by the Pages contract to enable purchasing pages with virtual balance.


```solidity
function burnGooForPages(address user, uint256 gooAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The user whose virtual goo balance we should burn from.|
|`gooAmount`|`uint256`|The amount of goo to burn from the user's virtual balance.|


### updateUserGooBalance

Update a user's virtual goo balance.


```solidity
function updateUserGooBalance(address user, uint256 gooAmount, GooBalanceUpdateType updateType) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The user whose virtual goo balance we should update.|
|`gooAmount`|`uint256`|The amount of goo to update the user's virtual balance by.|
|`updateType`|`GooBalanceUpdateType`|Whether to increase or decrease the user's balance by gooAmount.|


### mintReservedGobblers

Mint a number of gobblers to the reserves.

*Gobblers minted to reserves cannot comprise more than 20% of the sum of
the supply of goo minted gobblers and the supply of gobblers minted to reserves.*


```solidity
function mintReservedGobblers(uint256 numGobblersEach) external returns (uint256 lastMintedGobblerId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`numGobblersEach`|`uint256`|The number of gobblers to mint to each reserve.|


### getGobblerEmissionMultiple

Convenience function to get emissionMultiple for a gobbler.


```solidity
function getGobblerEmissionMultiple(uint256 gobblerId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gobblerId`|`uint256`|The gobbler to get emissionMultiple for.|


### getUserEmissionMultiple

Convenience function to get emissionMultiple for a user.


```solidity
function getUserEmissionMultiple(address user) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The user to get emissionMultiple for.|


### transferFrom


```solidity
function transferFrom(address from, address to, uint256 id) public override;
```

## Events
### GooBalanceUpdated

```solidity
event GooBalanceUpdated(address indexed user, uint256 newGooBalance);
```

### GobblerClaimed

```solidity
event GobblerClaimed(address indexed user, uint256 indexed gobblerId);
```

### GobblerPurchased

```solidity
event GobblerPurchased(address indexed user, uint256 indexed goblerId, uint256 price);
```

### LegendaryGobblerMinted

```solidity
event LegendaryGobblerMinted(address indexed user, uint256 indexed gobblerId, uint256[] burnedGobblerIds);
```

### ReservedGobblersMinted

```solidity
event ReservedGobblersMinted(address indexed user, uint256 lastMintedGobblerId, uint256 numGobblersEach);
```

### RandomnessFulfilled

```solidity
event RandomnessFulfilled(uint256 randomness);
```

### RandomnessRequested

```solidity
event RandomnessRequested(address indexed user, uint256 toBeRevealed);
```

### RandProviderUpgraded

```solidity
event RandProviderUpgraded(address indexed user, RandProvider indexed newRandProvider);
```

### GobblersRevealed

```solidity
event GobblersRevealed(address indexed user, uint256 numGobblers, uint256 lastRevealedId);
```

### ArtGobbled

```solidity
event ArtGobbled(address indexed user, uint256 indexed gobblerId, address indexed nft, uint256 id);
```

## Errors
### InvalidProof

```solidity
error InvalidProof();
```

### AlreadyClaimed

```solidity
error AlreadyClaimed();
```

### MintStartPending

```solidity
error MintStartPending();
```

### SeedPending

```solidity
error SeedPending();
```

### RevealsPending

```solidity
error RevealsPending();
```

### RequestTooEarly

```solidity
error RequestTooEarly();
```

### ZeroToBeRevealed

```solidity
error ZeroToBeRevealed();
```

### NotRandProvider

```solidity
error NotRandProvider();
```

### ReserveImbalance

```solidity
error ReserveImbalance();
```

### Cannibalism

```solidity
error Cannibalism();
```

### OwnerMismatch

```solidity
error OwnerMismatch(address owner);
```

### NoRemainingLegendaryGobblers

```solidity
error NoRemainingLegendaryGobblers();
```

### CannotBurnLegendary

```solidity
error CannotBurnLegendary(uint256 gobblerId);
```

### InsufficientGobblerAmount

```solidity
error InsufficientGobblerAmount(uint256 cost);
```

### LegendaryAuctionNotStarted

```solidity
error LegendaryAuctionNotStarted(uint256 gobblersLeft);
```

### PriceExceededMax

```solidity
error PriceExceededMax(uint256 currentprice);
```

### NotEnoughRemainingToBeRevealed

```solidity
error NotEnoughRemainingToBeRevealed(uint256 totalRemainingToBeRvealed);
```

### UnauthorizedCaller

```solidity
error UnauthorizedCaller(address caller);
```

## Structs
### LegendaryGobblerAuctionData
struct holding data required for legendary gobbler auctions.


```solidity
struct LegendaryGobblerAuctionData {
    uint128 startPrice;
    uint128 numSold;
}
```

### GobblerRevealsData
GOBBLER REVEAL STATE

Struct holding data required for gobbler reveals.


```solidity
struct GobblerRevealsData {
    uint64 randomSeed;
    uint64 nextRevealTimestamp;
    uint64 lastRevealedId;
    uint56 toBeRevealed;
    bool waitingForSeed;
}
```

## Enums
### GooBalanceUpdateType
*An enum for representing whether to
increase or decrease a user's goo balance.*


```solidity
enum GooBalanceUpdateType {
    INCREASE,
    DECREASE
}
```

