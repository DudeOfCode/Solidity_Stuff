//SPDX-License-Identifier:MIT
pragma solidity ^0.8.3;

contract Pggybank {
    address public owner;
    event Deposit(uint256 amnt);
    event Withdraw(uint256 amnt);

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {
        emit Deposit(msg.value);
    }

    function withdraw() external payable {
        require(msg.sender == owner, "Not the owner");
        emit Withdraw(address(this).balance);
        selfdestruct(payable(msg.sender));
    }
}
