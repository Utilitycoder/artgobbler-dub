// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/console.sol";
import {Vm} from "forge-std/Vm.sol";
import {ArtGobblers} from "../src/ArtGobblers.sol";
import {RandProvider} from "../src/utils/rand/RandProvider.sol";
import {ChainlinkV1RandProvider} from "../src/utils/rand/ChainlinkV1RandProvider.sol";
import {Goo} from "../src/Goo.sol";
import {Pages} from "../src/Pages.sol";
import {LinkToken} from "./utils/mocks/LinkToken.sol";
import {VRFCoordinatorMock} from "chainlink/v0.8/mocks/VRFCoordinatorMock.sol";

contract BenchmarksTest is DSTest {
    Vm internal vm = Vm(HEVM_ADDRESS);

    Utilities internal utils;
    address payable[] internal users;

    ArtGobblers private gobblers;
    VRFCoordinatorMock private vrfCoordinator;
    LinkToken private linkToken;
    RandProvider private randProvider;
    Goo private goo;
    Pages private pages;

    address gobblerAddress;
    address pageAddress;

    uint256 legendaryCost;

    bytes32 private keyHash;
    uint256 private fee;

    function setUp() public {
        vm.warp(1); // Otherwise mintStart will be swt to 0 and brick pages.mintFromGoo (type(uint256).max)

        utils = new Utilities();
        users = utils.createUsers(5);
        linkToken = new LinkToken();
        vrfCoordinator = new VRFCoordinatorMock(address(linkToken));

        // Gobblers contract will be deployed after 2 contracts deploys, and pages after 3.
        gobblerAddress = utils.predictContractAddress(address(this), 2);
        pageAddress = utils.predictContractAddress(address(this), 3);

        randProvider = new ChainlinkV1RandProvider(
            ArtGobblers(gobblerAddress),
            address(vrfCoordinator),
            address(linkToken),
            keyHash,
            fee
        );

        goo = new Goo(gobblerAddress, pageAddress);

        gobblers = new ArtGobblers(
            keccak256(abi.encodePacked(users[0])),
            block.timestamp,
            goo,
            Pages(pageAddress),
            address(0xBEEF),
            address(0xBEEF),
            randProvider,
            "base",
            "",
            keccak256(abi.encodePacked("provenance"))
        );

        pages = new Pages(block.timestamp, goo, address(0xBEEF), gobblers, "");

        vm.prank(address(gobblers));
        goo.mintForGobblers(address(this), type(uint192).max);
        gobblers.addGoo(type(uint96).max);

        mintPageToAddress(address(this), 9);
        mintGobblerToAddress(address(this), gobblers.LEGENDARY_AUCTION_INTERVAL());

        vm.warp(block.timestamp + 30 days);

        legendaryCost = gobblers.legendaryGobblerPrice();

        bytes32 requestId = gobblers.requestRandomSeed();
        uint256 randomness = uint256(keccak256(abi.encodePacked("seed")));
        vrfCoordinator.callBackWithRandomness(requestId, randomness, address(randProvider));
    }

    function mintGobblerToAddress(address addr, uint256 num) internal {
        for (uint256 i = 0; i < num; ++i) {
            vm.startPrank(address(gobblers));
            goo.mintForGobblers(addr, gobblers.gobblerPrice());
            vm.stopPrank();

            vm.prank(addr);
            gobblers.mintFromGoo(type(uint256).max, false);
        }
    }

    function mintPageToAddress(address addr, uint256 num) internal {
        for (uint256 i = 0; i < num; ++i) {
            vm.startPrank(address(gobblers));
            goo.mintForGobblers(addr, pages.pagePrice());
            vm.stopPrank();

            vm.prank(addr);
            pages.mintFromGoo(type(uint256).max, false);
        }
    }
}
