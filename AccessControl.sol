//SPDX-License-Identifier:MIT
pragma solidity ^0.8.10;

contract AccessControl {
    event GrantAccess(bytes32 _role, address _account);
    event RevokeAccess(bytes32 _role, address _account);
    mapping(bytes32 => mapping(address => bool)) public roles;
    bytes32 private constant ADMIN = keccak256(abi.encodePacked("OWNER"));
    bytes32 private constant USER = keccak256(abi.encodePacked("USER"));
    modifier OnlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "Not authorized");
        _;
    }

    constructor() {
        _grantRole(ADMIN, msg.sender);
    }

    function _grantRole(bytes32 _role, address _account)
        internal
        OnlyRole(ADMIN)
    {
        roles[_role][_account] = true;
        emit GrantAccess(_role, _account);
    }

    function grantRole(bytes32 _role, address _account)
        external
        OnlyRole(ADMIN)
    {
        _grantRole(_role, _account);
    }

    function _revokeRole(bytes32 _role, address _account)
        external
        OnlyRole(ADMIN)
    {
        roles[_role][_account] = false;
        emit RevokeAccess(_role, _account);
    }
}
