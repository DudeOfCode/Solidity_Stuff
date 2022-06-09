//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

contract Ethwallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function sendeth(uint256 _amount) external payable {
        require(msg.sender == owner, "Not the owner");
        payable(msg.sender).transfer(_amount);
    }

    function getbal() external pure returns (uint256) {
        return address(this).balance;
    }
}
