// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {stdError} from "forge-std/Test.sol";
import {ArtGobblers, FixedPointMathLib} from "../src/ArtGobblers.sol";
import {Goo} from "../src/Goo.sol";
import {Pages} from "../src/Pages.sol";
import {GobblerReserve} from "../src/utils/GobblerReserve.sol";
import {RandProvider} from "../src/utils/rand/RandProvider.sol";
import {ChainlinkV1RandProvider} from "../src/utils/rand/ChainlinkV1RandProvider.sol";
import {LinkToken} from "./utils/mocks/LinkToken.sol";
import {VRFCoordinatorMock} from "chainlink/v0.8/mocks/VRFCoordinatorMock.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {MockERC1155} from "solmate/test/utils/mocks/MockERC1155.sol";
import {LibString} from "solmate/utils/LibString.sol";
import {fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";

/// @notice Unit test for Art Gobbler Contract.
contract ArtGobblersTest is DSTestPlus {
    using LibString for uint256;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    Utilities internal utils;
    address payable[] internal users;

    ArtGobblers internal gobblers;
    VRFCoordinatorMock internal vrfCoordinator;
    LinkToken internal linkToken;
    Goo internal goo;
    Pages internal pages;
    GobblerReserve internal team;
    GobblerReserve internal community;
    RandProvider internal randProvider;

    bytes32 private keyHash;
    uint256 private fee;

    uint256[] ids;

    ////////////// SETUP //////////////

    function setUp() public {
        utils = new Utilities();
        users = utils.createUsers(5);
        linkToken = new LinkToken();
        vrfCoordinator = new VRFCoordinatorMock(address(linkToken));

        // Gobblers contract will be deployed after 4 contract deploys, and pages after 5.
        address gobblerAddress = utils.predictContractAddress(address(this), 4);
        address pagesAddress = utils.predictContractAddress(address(this), 5);

        team = new GobblerReserve(ArtGobblers(gobblerAddress), address(this));
        community = new GobblerReserve(ArtGobblers(gobblerAddress), address(this));
        randProvider = new ChainlinkV1RandProvider(
            ArtGobblers(gobblerAddress),
            address(vrfCoordinator),
            address(linkToken),
            keyHash,
            fee
        );

        goo = new Goo(
            //gobblers
            utils.predictContractAddress(address(this), 1),
            //Pages
            utils.predictContractAddress(address(this), 2)
        );

        gobblers = new ArtGobblers(
            keccak256(abi.encodePacked(users[0])),
            block.timestamp,
            goo,
            Pages(pagesAddress),
            address(team),
            address(community),
            randProvider,
            "base",
            "",
            keccak256(abi.encodePacked("provenance"))
        );

        pages = new Pages(block.timestamp, goo, address(0xBEEF), gobblers, "");
    }

    ///////// MINT TESTS ///////////

    /// @notice Test that minting from the mintlist before minting starts fails.
    function testMintFromMintlistBeforeMintingStarts() public {
        vm.warp(block.timestamp - 1);
        address user = users[0];
        bytes32[] memory proof;
        vm.prank(user);
        vm.expectRevert(ArtGobblers.MintStartPending.selector);
        gobblers.claimGobbler(proof);
    }

    /// @notice test that you can mint from mintlisr successfully
    function testMintFromMintlist() public {
        address user = users[0];
        bytes32[] memory proof;
        vm.prank(user);
        gobblers.claimGobbler(proof);
        // verify gobbler ownership
        assertEq(gobblers.ownerOf(1), user);
        assertEq(gobblers.balanceOf(user), 1);
    }

    /// @notice Test that minting from the mintlist twice fails.
    function testMintingFromMintlistTwiceFails() public {
        address user = users[0];
        bytes32[] memory proof;
        vm.startPrank(user);
        gobblers.claimGobbler(proof);

        vm.expectRevert(ArtGobblers.AlreadyClaimed.selector);
        gobblers.claimGobbler(proof);
    }

    /// @notice Test that an invalid mintlist proof reverts
    function testMintNotInMintlist() public {
        bytes32[] memory proof;
        vm.expectRevert(ArtGobblers.InvalidProof.selector);
        gobblers.claimGobbler(proof);
    }

    /// @notice Test that you can successfully mint from goo.
    function testMintFromGoo() public {
        uint256 cost = gobblers.gobblerPrice();
        vm.prank(address(gobblers));
        goo.mintForGobblers(users[0], cost);
        vm.prank(users[0]);
        gobblers.mintFromGoo(type(uint256).max, false);
        assertEq(gobblers.ownerOf(1), users[0]);
    }

    /// @notice test that trying to mint with insufficient balance reverts.
    function testMintInsufficientBalance() public {
        vm.prank(users[0]);
        vm.expectRevert(stdError.arithmeticError);
        gobblers.mintFromGoo(type(uint256).max, false);
    }

    /// @notice Test that you can successfully mint from goo.
    function testMintFromGooBalance() public {
        uint256 cost = gobblers.gobblerPrice();
        // mint initial gobbler
        vm.prank(address(gobblers));
        goo.mintForGobblers(users[0], cost);
        vm.prank(users[0]);
        gobblers.mintFromGoo(type(uint256).max, false);
        assertEq(gobblers.balanceOf(users[0]), 1);
        //warp for reveals
        vm.warp(block.timestamp + 1 days);
        setRandomnessAndReveal(1, "seed");
        //warp until balance is larger than cost
        vm.warp(block.timestamp + 3 days);
        uint256 userBalance = goo.balanceOf(users[0]);
        console.log(userBalance);
        uint256 initialBalance = gobblers.gooBalance(users[0]);
        uint256 gobblerPrice = gobblers.gobblerPrice();
        console.log("gobblerPrice", gobblerPrice);
        assertTrue(initialBalance > gobblerPrice);
        console.log("newPrice", gobblerPrice);
        console.log("balance", initialBalance);
        //mint from balance
        vm.prank(users[0]);
        gobblers.mintFromGoo(type(uint256).max, true);
        //assert owner is correct
        assertEq(gobblers.ownerOf(2), users[0]);
        //assert balance went up by expected amount
        uint256 finalBalance = gobblers.gooBalance(users[0]);
        uint256 paidGoo = initialBalance - finalBalance;
        assertEq(paidGoo, gobblerPrice);
    }

    /// @notice Test that you can't mint with insufficient balance
    function testMintFromBalanceInsufficient() public {
        vm.prank(users[0]);
        vm.expectRevert(stdError.arithmeticError);
        gobblers.mintFromGoo(type(uint256).max, true);
    }

    /// @notice Test that if mint price exceeds max it reverts.
    function testMintPriceExceededMax() public {
        uint256 cost = gobblers.gobblerPrice();
        vm.prank(address(gobblers));
        goo.mintForGobblers(users[0], cost);
        vm.prank(users[0]);
        vm.expectRevert(abi.encodeWithSelector(ArtGobblers.PriceExceededMax.selector, cost)); // we won't use encodeWithSelector if the custom error doesn't take a parameter
        gobblers.mintFromGoo(cost - 1, false);
    }

    /// @notice Test that the initial gobbler price is what we expect. 
    function testInitialGobblerPrice() public {
        // warp to the largest sale time so that the gobbler price equals the target price. 
        vm.warp(block.timestamp + fromDaysWadUnsafe(gobblers.getTargetSaleTime(1e18)));

        uint256 cost = gobblers.gobblerPrice();
        assertRelApproxEq(cost, uint256(gobblers.targetPrice()), 0.00001e18);
    }

    /// @notice Test that minting resolved gobblers fails if there are no mints. 
    function testMintReservedGobblersFailsWithNoMints() public {
        vm.expectRevert(ArtGobblers.ReserveImbalance.selector);
        gobblers.mintReservedGobblers(1);
    }

    /// @notice Test that reserved gobblers can be minted under fair circumstances. 
    function testCanMintReserved() public {
        mintGobblerToAddress(users[0], 8);
        gobblers.mintReservedGobblers(1);
        assertEq(gobblers.ownerOf(9), address(team));
        assertEq(gobblers.ownerOf(10), address(community));
        assertEq(gobblers.balanceOf(address(team)), 1);
        assertEq(gobblers.balanceOf(address(community)), 1);
    }

    /// @notice Test multiple reserved gobblers can be minted under fair circumstances. 
    function testCanMintMultipleReserved() public {
        mintGobblerToAddress(users[0], 18);

        gobblers.mintReservedGobblers(2);
        assertEq(gobblers.ownerOf(19), address(team));
        assertEq(gobblers.ownerOf(20), address(team));
        assertEq(gobblers.ownerOf(21), address(community));
        assertEq(gobblers.ownerOf(22), address(community));
        assertEq(gobblers.balanceOf(address(team)), 2);
        assertEq(gobblers.balanceOf(address(community)), 2);
    }

    /// @notice Test minting reserved gobblers fails if not enough have gobblers been minted. 
    function testCantMintTooFastReserved() public {
        mintGobblerToAddress(users[0], 18);

        vm.expectRevert(ArtGobblers.ReserveImbalance.selector);
        gobblers.mintReservedGobblers(3);
    }

    /// @notice Test minting reserved gobblers fails one by one if not enough  have gobblers been minted. 
    function testCantMintTooFastReservedOneByOne() public {
        mintGobblerToAddress(users[0], 90);

        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);
        gobblers.mintReservedGobblers(1);

        vm.expectRevert(ArtGobblers.ReserveImbalance.selector);
        gobblers.mintReservedGobblers(1);
    }

    /// @notice Test that user can mint page with their virtual balance. 
    function testCanMintPageFromVirtualBalance() public {
        uint256 cost = gobblers.gobblerPrice();
        //mint initial gobbler
        vm.prank(address(gobblers));
        goo.mintForGobblers(users[0], cost);
        vm.prank(users[0]);
        gobblers.mintFromGoo(type(uint256).max, false);
        //warp for reveals
        vm.warp(block.timestamp + 1 days);
        setRandomnessAndReveal(1, "seed");
        //warp until balance is larger than cost
        vm.warp(block.timestamp + 3 days);
        uint256 initialBalance = gobblers.gooBalance(users[0]);
        uint256 pagePrice = pages.pagePrice();
        console.log(pagePrice);
        assertTrue(initialBalance > pagePrice);
        //Mint from balance 
        vm.prank(users[0]);
        pages.mintFromGoo(type(uint256).max, true);
        //assert owner is correct
        assertEq(pages.ownerOf(1), users[0]);
        //assert balance went down by expected amount.
        uint256 finalBalance = gobblers.gooBalance(users[0]);
        uint256 paidGoo = initialBalance - finalBalance;
        assertEq(paidGoo, pagePrice);
    }

    function testCannotMintPageWithInsufficientBalance() public {
        uint256 cost = gobblers.gobblerPrice();
        // mint initial balance. 
        vm.prank(address(gobblers));
        goo.mintForGobblers(users[0], cost);
        vm.prank(users[0]);
        gobblers.mintFromGoo(type(uint256).max, false);
        //warp for reveals
        vm.warp(block.timestamp + 1 days);
        setRandomnessAndReveal(1, "seed");
        // try to mint from balance
        vm.prank(users[0]);
        console.log(goo.balanceOf(users[0]));
        vm.expectRevert(stdError.arithmeticError);
        pages.mintFromGoo(type(uint256).max, true);
    }

    /////////////////// PRICING TEST //////////////////

    /// @notice Test VRGDA behaviour when selling at target rate
    function testPricingBasic() public {
        // VRGDA targets this number of mints at given time.
        uint256 timeDelta = 120 days;
        uint256 numMint = 876;

        vm.warp(block.timestamp + timeDelta);

        for (uint256 i = 0; i < numMint; ++i) {
            vm.startPrank(address(gobblers));
            uint256 price = gobblers.gobblerPrice();
            goo.mintForGobblers(users[0], price);
            vm.stopPrank();
            vm.prank(users[0]);
            gobblers.mintFromGoo(price, false);
        }

        uint256 targetPrice = uint256(gobblers.targetPrice());
        uint256 finalPrice = gobblers.gobblerPrice();

        // Equal within 3 percent since num mint is rounded from true decimal amount. 
        assertRelApproxEq(finalPrice, targetPrice, 0.03e18);
    }

    /// @notice Pricing function should NOT revert when trying to price the last mintable gobbler.
    function testDoesNotRevertEarly() public view {
        //This is the last gobbler we expect to mint. 
        int256 maxMintable = int256(gobblers.MAX_MINTABLE()) * 1e18;
        //This call should NOT revert, since we should have a target date for the last mintable gobbler. 
        gobblers.getTargetSaleTime(maxMintable);
    }

    /// @notice Pricing function should revert when trying to price beyond the last mintable gobbler. 
    function testDoesRevertWhenExpected() public {
        // one plus the max number of mintable gobblers. 
        int256 maxMintablePlusOne = int256(gobblers.MAX_MINTABLE() +1) * 1e18;
        //This call should revert, since there should be no target date beyond max mintable gobbblers. 
        vm.expectRevert("UNDEFINED");
        gobblers.getTargetSaleTime(maxMintablePlusOne);
    }

    ////////////// LEGENDARY GOBBLERS ////////////
    
    /// @notice Test that attempting to mint before start time reverts. 
    function testLegendaryGobblerMintBeforeStart() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ArtGobblers.LegendaryAuctionNotStarted.selector, 
                gobblers.LEGENDARY_AUCTION_INTERVAL()
            )
        );
        vm.prank(users[0]);
        gobblers.mintLegendaryGobbler(ids);
    }

    /// @notice test that Legendary Gobbler initial price is what we expect. 
    function testLegendaryGobblerTargetPrice() public {
        // Start of initial auction after initial interval is minted.
        mintGobblerToAddress(users[0], gobblers.LEGENDARY_AUCTION_INTERVAL());
        uint256 cost = gobblers.legendaryGobblerPrice();
        // Initial auction should start at a cost of 69.
        assertEq(cost, 69);
    }

    /// @notice Test that auction ends at a price of 0. 
    function testLegendaryGobblerFinalPrice() public {
        // Mint 2 full intervals.
        mintGobblerToAddress(users[0], gobblers.LEGENDARY_AUCTION_INTERVAL() * 2);
        uint256 cost = gobblers.legendaryGobblerPrice();
        // Auction price should be 0 after full interval decay. 
        assertEq(cost, 0);
    }

    /// @notice Test that auction ends at a price of 0 even after the interval. 
    function testLegendaryGobblerPastFinalPrice() public {
        // Mint 3 full intervals. 
        vm .warp(block.timestamp + 600 days);
        mintGobblerToAddress(users[0], gobblers.LEGENDARY_AUCTION_INTERVAL() * 3);
        uint256 cost = gobblers.legendaryGobblerPrice();
        // Auction price should be 0 after full interval decay.
        assertEq(cost, 0);
    }



    /// @notice Mint a number of gobblers to the given address
    function mintGobblerToAddress(address addr, uint256 num) internal {
        for (uint256 i = 0; i < num; ++i) {
            vm.startPrank(address(gobblers));
            goo.mintForGobblers(addr, gobblers.gobblerPrice());
            vm.stopPrank();

            uint256 gobblersOwnedBefore = gobblers.balanceOf(addr);

            vm.prank(addr);
            gobblers.mintFromGoo(type(uint256).max, false);

            assertEq(gobblers.balanceOf(addr), gobblersOwnedBefore + 1);
        }
    }

    /// @notice Call back vrf with randomness and reveal gobblers.
    function setRandomnessAndReveal(uint256 numReveal, string memory seed) internal {
        bytes32 requestId = gobblers.requestRandomSeed();
        uint256 randomness = uint256(keccak256(abi.encodePacked(seed)));
        // call back from coordinator
        vrfCoordinator.callBackWithRandomness(requestId, randomness, address(randProvider));
        gobblers.revealGobblers(numReveal);
    }
}
