//SPDX-License-Identifier:MIT
pragma solidity ^0.8.1;

contract Mytimelock {
    error NotOwnerEror();
    error AlreadylinedUpError(bytes32 txId);
    error NotinRangeError(uint256 blockTime, uint256 timestamp);
    error NotlinedUpError(bytes32 txId);
    error BeyondTimestampError(uint256 blockTime, uint256 timestamp);
    error LessThanTimeStamp(uint256 blockTime, uint256 timestamp);
    error TxFailedError();

    event lineUp(
        bytes32 txId,
        address target,
        uint256 value,
        bytes data,
        string func,
        uint256 timestamp
    );
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    uint256 public constant MINI_DELAY = 10;
    uint256 public constant MAXI_DELAY = 1000;
    uint256 public constant EXTRA_PERIOD = 1000;
    mapping(bytes32 => bool) public linedUp;
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert NotOwnerEror();
        }
        _;
    }

    function gettxId(
        address _target,
        uint256 _value,
        bytes calldata _data,
        string calldata _func,
        uint256 _timestamp
    ) public pure returns (bytes32 txId) {
        txId = keccak256(abi.encode(_target, _value, _data, _func, _timestamp));
    }

    function queue(
        address _target,
        uint256 _value,
        bytes calldata _data,
        string calldata _func,
        uint256 _timestamp
    ) public payable onlyOwner {
        bytes32 txId = gettxId(_target, _value, _data, _func, _timestamp);
        if (linedUp[txId]) {
            revert AlreadylinedUpError(txId);
        }
        if (
            block.timestamp < _timestamp + MINI_DELAY ||
            block.timestamp > _timestamp + MAXI_DELAY
        ) {
            revert NotinRangeError(block.timestamp, _timestamp);
        }
        linedUp[txId] = true;
        emit lineUp(txId, _target, _value, _data, _func, _timestamp);
    }

    function execute(
        address _target,
        uint256 _value,
        bytes calldata _data,
        string calldata _func,
        uint256 _timestamp
    ) public payable onlyOwner returns (bytes memory) {
        bytes32 txId = gettxId(_target, _value, _data, _func, _timestamp);
        if (!linedUp[txId]) {
            revert NotlinedUpError(txId);
        }
        linedUp[txId] = false;
        if (block.timestamp > _timestamp + EXTRA_PERIOD) {
            revert BeyondTimestampError(block.timestamp, _timestamp);
        }
        if (block.timestamp < _timestamp) {
            revert LessThanTimeStamp(block.timestamp, _timestamp);
        }
        linedUp[txId] = false;
        bytes memory data;
        if (bytes(_func).length > 0) {
            abi.encodePacked(bytes4(keccak256(bytes(_func))), data);
        } else {
            data = _data;
        }

        (bool ok, bytes memory res) = _target.call{value: _value}(data);
        if (!ok) {
            revert TxFailedError();
        }
        return res;
    }
}
