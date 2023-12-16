// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol"; 
import { MyToken } from "../src/MyToken.sol";

contract DeployMyToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether; // 1 million tokens with 18 decimals
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY =         0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    uint256 public deployerKey;

    function run() external returns(MyToken) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployerKey);
        MyToken myToken = new MyToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        return myToken;
    }
}