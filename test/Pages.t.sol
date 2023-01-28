// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {Utilities} from "./utils/Utilities.sol";
import {Vm} from "forge-std/Vm.sol";
import {stdError} from "forge-std/Test.sol";
import {Goo} from "../src/Goo.sol";
import {Pages} from "../src/Pages.sol";
import {ArtGobblers} from "../src/ArtGobblers.sol";
import {console} from "./utils/Console.sol";
import {fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";

contract PagesTest is DSTestPlus {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    Utilities internal utils;
    address payable[] internal users;
    address internal mintAuth;

    address internal user;
    Goo internal goo;
    Pages internal pages;
    uint256 mintStart;

    address internal community = address(0xBEEF);

    function setUp() public {
        // Avoid starting at timestamp at 0 for ease of testing.
        vm.warp(block.timestamp + 1);

        utils = new Utilities();
        users = utils.createUsers(5);

        goo = new Goo(
            // Gobblers
            address(this),
            // Pages
            utils.predictContractAddress(address(this), 1)
        );

        pages = new Pages(
            block.timestamp,
            goo,
            community,
            ArtGobblers(address(this)), 
            ""
        );

        user = users[1];
    }

    function testMintBeforeSetMint() public {
        vm.expectRevert(stdError.arithmeticError);
        vm.prank(user);
        pages.mintFromGoo(type(uint256).max, false);
    }

    function testMintBeforeStart() public {
        vm.warp(block.timestamp - 1);

        vm.expectRevert(stdError.arithmeticError);
        vm.prank(user);
        pages.mintFromGoo(type(uint256).max, false);
    }

    function testTargetPrice() public {
        // Warp to the target sale time so that the page price equals the target price. 
        vm.warp(block.timestamp + fromDaysWadUnsafe(pages.getTargetSaleTime(1e18)));

        uint256 cost = pages.pagePrice();
        assertRelApproxEq(cost, uint256(pages.targetPrice()), 0.00001e18);
    }
    
}