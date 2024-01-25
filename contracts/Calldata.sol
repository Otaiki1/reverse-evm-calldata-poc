// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReadCalldata {
    function readData(uint256 num, address addr) external pure returns (uint256, address) {
        return (num, addr);
    }
}

contract ReadDynamicCalldata {
    function readArray(uint256[] calldata arr) external pure returns (uint256[] memory) {
        return arr;
    }
}


// contract MultiCall {
//     function getBalances(address[] calldata addresses) external view returns (uint256[] memory) {
//         uint256[] memory balances = new uint256[](addresses.length);
//         for (uint256 i = 0; i < addresses.length; i++) {
//             balances[i] = addresses[i].balance;
//         }
//         return balances;
//     }
// }

// calldata : 0x69168c1d00000000000000000000000000000000000000000000000000000000000000170000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4
//calldata: 0xc77f7f64000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000017000000000000000000000000000000000000000000000000000000000000002f0000000000000000000000000000000000000000000000000000000000000018