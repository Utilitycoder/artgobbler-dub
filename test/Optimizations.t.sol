// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

contract OptimizationsTest is DSTestPlus {
    function testFuzzCurrentIdMultipleBranchlessOptimization(uint256 swapIndex) public {
        /*//////////////////////////////////////////////////////////////
                                  BRANCHLESS
        //////////////////////////////////////////////////////////////*/

        uint256 newCurrentIdMutlipleBranchless = 9; //for beyond 7963
        assembly {
            // prettier-ignore
            newCurrentIdMutlipleBranchless := sub(sub(sub(
                newCurrentIdMutlipleBranchless,
                lt(swapIndex, 7964)),
                lt(swapIndex, 5673)),
                lt(swapIndex, 3055)
            )
        }

        /*//////////////////////////////////////////////////////////////
                                  BRANCHED
        //////////////////////////////////////////////////////////////*/

        uint256 newCurrentIdMutlipleBranched = 9; // For beyond 7963.
        if (swapIndex <= 3054) newCurrentIdMutlipleBranched = 6;
        else if (swapIndex <= 5672) newCurrentIdMutlipleBranched = 7;
        else if (swapIndex <= 7963) newCurrentIdMutlipleBranched = 8;

        /*//////////////////////////////////////////////////////////////
                                EQUIVALENCE
        //////////////////////////////////////////////////////////////*/

        assertEq(newCurrentIdMutlipleBranchless, newCurrentIdMutlipleBranched);
    }
}
