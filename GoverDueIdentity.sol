// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// This contract provides identity verification for government agencies and registered citizens.
contract GoverDueIdentity {
    address public admin;  // Contract administrator

    enum Role { Citizen, GovernmentOfficial, Admin }

    struct Identity {
        string name;          // Identity name
        Role role;            // Assigned role
        bool exists;          // Identity existence status
    }

    mapping(address => Identity) public identities;

    event IdentityRegistered(address indexed user, string name, Role role);
    event IdentityUpdated(address indexed user, string name, Role role);
    event IdentityRevoked(address indexed user);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyRegistered(address _user) {
        require(identities[_user].exists, "Identity does not exist");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Register a new identity
    function registerIdentity(address _user, string memory _name, Role _role) public onlyAdmin {
        require(!identities[_user].exists, "Identity already exists");

        identities[_user] = Identity({
            name: _name,
            role: _role,
            exists: true
        });

        emit IdentityRegistered(_user, _name, _role);
    }

    /// @notice Update identity details
    function updateIdentity(address _user, string memory _name, Role _role) public onlyAdmin onlyRegistered(_user) {
        identities[_user].name = _name;
        identities[_user].role = _role;

        emit IdentityUpdated(_user, _name, _role);
    }

    /// @notice Revoke an identity
    function revokeIdentity(address _user) public onlyAdmin onlyRegistered(_user) {
        delete identities[_user];

        emit IdentityRevoked(_user);
    }

    /// @notice Get identity details
    function getIdentity(address _user) public view returns (string memory name, Role role, bool exists) {
        require(identities[_user].exists, "Identity does not exist");

        Identity memory identity = identities[_user];
        return (identity.name, identity.role, identity.exists);
    }

    /// @notice Verify if a user has a specific role
    function hasRole(address _user, Role _role) public view returns (bool) {
        require(identities[_user].exists, "Identity does not exist");
        return identities[_user].role == _role;
    }
}
