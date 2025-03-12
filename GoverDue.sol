// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Government Management Contract
/// @notice This contract manages government agencies, policy proposals, and citizen voting.
contract GoverDue {
    address public admin;

    struct GovernmentAgency {
        string name;
        string description;
        address head;
        bool exists;
    }

    struct Policy {
        string title;
        string description;
        uint256 voteCount;
        bool exists;
    }

    mapping(bytes32 => GovernmentAgency) public agencies;
    mapping(bytes32 => Policy) public policies;
    mapping(address => bool) public registeredCitizens;

    event AgencyAdded(bytes32 indexed agencyId, string name);
    event AgencyRemoved(bytes32 indexed agencyId);
    event PolicyProposed(bytes32 indexed policyId, string title);
    event PolicyVoted(bytes32 indexed policyId, address voter);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addAgency(string memory _name, string memory _description, address _head) public onlyAdmin {
        bytes32 agencyId = keccak256(abi.encodePacked(_name, _head));
        require(!agencies[agencyId].exists, "Agency already exists");

        agencies[agencyId] = GovernmentAgency({
            name: _name,
            description: _description,
            head: _head,
            exists: true
        });

        emit AgencyAdded(agencyId, _name);
    }

    function removeAgency(bytes32 _agencyId) public onlyAdmin {
        require(agencies[_agencyId].exists, "Agency does not exist");

        delete agencies[_agencyId];
        emit AgencyRemoved(_agencyId);
    }

    function proposePolicy(string memory _title, string memory _description) public onlyAdmin {
        bytes32 policyId = keccak256(abi.encodePacked(_title, block.timestamp));
        require(!policies[policyId].exists, "Policy already exists");

        policies[policyId] = Policy({
            title: _title,
            description: _description,
            voteCount: 0,
            exists: true
        });

        emit PolicyProposed(policyId, _title);
    }

    function registerCitizen(address _citizen) public onlyAdmin {
        require(!registeredCitizens[_citizen], "Citizen is already registered");
        registeredCitizens[_citizen] = true;
    }

    function votePolicy(bytes32 _policyId) public {
        require(registeredCitizens[msg.sender], "Only registered citizens can vote");
        require(policies[_policyId].exists, "Policy does not exist");

        policies[_policyId].voteCount++;
        emit PolicyVoted(_policyId, msg.sender);
    }
}
