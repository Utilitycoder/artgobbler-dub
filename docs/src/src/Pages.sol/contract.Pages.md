# Pages
[Git Source](https://github.com/Utilitycoder/artgobbler-dub/blob/3c22f2fc754088c788fa1c2d53754e6ba88dfed3/src/Pages.sol)

**Inherits:**
[PagesERC721](/src/utils/token/PagesERC721.sol/contract.PagesERC721.md), LogisticToLinearVRGDA

**Author:**
lawal B

Pages is an ERC721 that can hold custom art


## State Variables
### goo
Addresses

the addres of the goo ERC20 token contract.


```solidity
Goo public immutable goo;
```


### community
The address of which receives pages reserved for the community


```solidity
address public immutable community;
```


### BASE_URI
URIs

Base URI for minted pages.


```solidity
string public BASE_URI;
```


### mintStart
VRGDA INPUT STATE

Timestamp for the start of the VRGDA mint.


```solidity
uint256 public immutable mintStart;
```


### currentId
Id of the most recently minted page.

*Will be 0 if no pages has been minted yet.*


```solidity
uint128 public currentId;
```


### numMintedForCommunity
COMMUNITY PAGES STATE

The number of pages minted to the community reserve.


```solidity
uint128 public numMintedForCommunity;
```


### SWITCH_DAY_WAD
PRICING CONSTANTS

*The day the switch from a logistic to translated linear VRGDA is targeted to occur.*

*Represented as an 18 decimal fixed point number.*


```solidity
int256 internal constant SWITCH_DAY_WAD = 233e18;
```


### SOLD_BY_SWITCH_WAD
The minimum amount of pages that must be sold for the VRGDA issuance schedule to switch from logistic to the "post switch" translated linear formula

*Computed off-chain by plugging SWITCH_DAY_WAD into the uninverted pacing formula.*

*Represented as an 18 decimal fixed point number.*


```solidity
int256 internal constant SOLD_BY_SWITCH_WAD = 8336.760939794622713006e18;
```


## Functions
### constructor

CONSTRUCTOR

Sets VRGDA parameters, mint start, relevant addresses, and base URI.


```solidity
constructor(uint256 _mintStart, Goo _goo, address _community, ArtGobblers _artGobblers, string memory _baseUri)
    PagesERC721(_artGobblers, "Pages", "PAGE")
    LogisticToLinearVRGDA(4.2069e18, 0.31e18, 9000e18, 0.014e18, SOLD_BY_SWITCH_WAD, SWITCH_DAY_WAD, 9e18);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_mintStart`|`uint256`|Timestamp for the start of the VRGDA mint.|
|`_goo`|`Goo`|Address of the Goo contract.|
|`_community`|`address`|Address of the community reserve.|
|`_artGobblers`|`ArtGobblers`|Address of the ArtGobblers contract.|
|`_baseUri`|`string`|Base URI for token metadata.|


### mintFromGoo

Mint a page with goo, burning the cost.


```solidity
function mintFromGoo(uint256 maxPrice, bool useVirtualBalance) external returns (uint256 pageId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxPrice`|`uint256`|Maximum price to pay to mint the page.|
|`useVirtualBalance`|`bool`|Whether the the cost is paid from the user's virtual goo balance, or from their ERC20 goo balance.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`pageId`|`uint256`|The id of the page that was minted.|


### pagePrice

Calculate tje mint cost of a page.

*If the number of sales is below a predetermined threshold , we use the VRGDA pricing algorithm, otherwise we use the post-switch pricing formula.*

*Reverts due to underflow if mintng hasn't started yet. Done to save gas.*


```solidity
function pagePrice() public view returns (uint256);
```

### mintCommunityPages

COMMUNITY PAGES MINTING LOGIC

Mint a number of the pages to the community reserve.

*Pages minted to the reserve cannot comprie more than 10% of the sum of the supply goo minted pages and the supply of pages minted to the community reserve.*


```solidity
function mintCommunityPages(uint256 numPages) external returns (uint256 lastMintedPageId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`numPages`|`uint256`|The number of pages to mint to the reserve.|


### tokenURI

TOKEN URI LOGIC

Returns a page's URI if it has been minted.


```solidity
function tokenURI(uint256 pageId) public view virtual override returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pageId`|`uint256`|The id of the page to get the URI for.|


## Events
### PagePurchased
EVENTS


```solidity
event PagePurchased(address indexed user, uint256 indexed pageId, uint256 price);
```

### CommunityPagesMinted

```solidity
event CommunityPagesMinted(address indexed user, uint256 lastMintedPageId, uint256 numPages);
```

## Errors
### ReserveImbalance
ERRORS


```solidity
error ReserveImbalance();
```

### PriceExceededMax

```solidity
error PriceExceededMax(uint256 currentPrice);
```

