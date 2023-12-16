// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test, console } from "forge-std/Test.sol";
import { DeployMyToken } from "../script/DeployMyToken.s.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { MyToken } from "../src/MyToken.sol";


    interface MintableToken {
        function mint(address, uint256) external;
    }

    contract MyTokenTest is StdCheats, Test {
        uint256 BOB_STARTING_AMOUNT = 100 ether;

        MyToken public myToken;
        DeployMyToken public deployer;
        address public deployerAddress;
        address bob;
        address alice;

        function setUp() public {
            deployer = new DeployMyToken();
            myToken = deployer.run();

            bob = makeAddr("bob");
            alice = makeAddr("alice");

            deployerAddress = vm.addr(deployer.deployerKey());
            vm.prank(deployerAddress);
            myToken.transfer(bob, BOB_STARTING_AMOUNT);
        }

        function testInitialSupply() public {
            assertEq(myToken.totalSupply(), deployer.INITIAL_SUPPLY());
        }

        function testUsersCanMint() public {
            vm.expectRevert();
            MintableToken(address(myToken)).mint(address(this), 1);
        }

        function testAllowances() public {
            uint256 initialAllowance = 1000;

            // Alice approves bob to spend tokens on her behalf
            vm.prank(bob);
            myToken.approve(alice, initialAllowance);
            uint256 transferAmount = 500;

            vm.prank(alice);
            myToken.transferFrom(bob, alice, transferAmount);

            assert(myToken.balanceOf(alice), transferAmount);
            assert(myToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);

        }
}  //Try to increase the coverage with some more tests