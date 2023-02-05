// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "./utils/Console.sol";

contract SimpleStorageContract {
    uint256 public value;

    function set(uint256 _value) public {
        value = _value;
    }

}

contract ForkTest is Test {
    uint256 internal mainnetFork;
    uint256 internal polygonFork;

    string internal MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
    string internal POLYGON_RPC_URL = vm.envString("POLYGON_API_KEY_URL");

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        polygonFork = vm.createFork(POLYGON_RPC_URL);
    }

        // demonstrate fork ids are unique
        function testForkIdDiffer() public view {
            assert(mainnetFork != polygonFork);
        }
    
        // select a specific fork
        function testCanSelectFork() public {
            // select the fork
            vm.selectFork(mainnetFork);
            assertEq(vm.activeFork(), mainnetFork);
            console.log(mainnetFork);
    
            // from here on data is fetched from the `mainnetFork` if the EVM requests it and written to the storage of `mainnetFork`
        }
    
        // manage multiple forks in the same test
        function testCanSwitchForks() public {
            vm.selectFork(mainnetFork);
            assertEq(vm.activeFork(), mainnetFork);
    
            vm.selectFork(polygonFork);
            assertEq(vm.activeFork(), polygonFork);
        }
    
        // forks can be created at all times
        function testCanCreateAndSelectForkInOneStep() public {
            // creates a new fork and also selects it
            uint256 anotherFork = vm.createSelectFork(MAINNET_RPC_URL);
            assertEq(vm.activeFork(), anotherFork);
        }
    
        // set `block.number` of a fork
        function testCanSetForkBlockNumber() public {
            vm.selectFork(mainnetFork);
            vm.rollFork(1337000);
    
            assertEq(block.number, 1337000);
        }

        function testFailCreateContract() public {
            // Select fork and confirm it is active
            vm.selectFork(mainnetFork);
            assertEq(vm.activeFork(), mainnetFork);

            SimpleStorageContract simple = new SimpleStorageContract();

            simple.set(100);
            assertEq(simple.value(), 100);

            vm.selectFork(polygonFork);
            simple.value();
        }

        /// @notice create a new persistent contract while fork is active
        function testCreatePersistentContract() public {
            vm.selectFork(mainnetFork);
            SimpleStorageContract simple = new SimpleStorageContract();
            simple.set(100);
            assertEq(simple.value(), 100);

            vm.makePersistent(address(simple));
            assert(vm.isPersistent(address(simple)));

            vm.selectFork(polygonFork);
            assert(vm.isPersistent(address(simple)));

            assertEq(simple.value(), 100);
        }
}