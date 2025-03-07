// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GoverDueFunds - Government Financial Management
/// @notice This contract extends GoverDue by introducing budget allocation, expenditure tracking, and fund transfers.
contract GoverDueFunds {
    address public admin;  // Contract administrator

    struct GovernmentAgency {
        string name;          // Agency name
        address head;         // Agency head (wallet address)
        uint256 allocatedFunds;  // Budget allocated to the agency
        uint256 spentFunds;      // Amount spent
        bool exists;          // Whether the agency exists
    }

    mapping(bytes32 => GovernmentAgency) public agencies;

    event FundsAllocated(bytes32 indexed agencyId, uint256 amount);
    event FundsSpent(bytes32 indexed agencyId, uint256 amount);
    event FundsTransferred(bytes32 indexed fromAgencyId, bytes32 indexed toAgencyId, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyAgencyHead(bytes32 _agencyId) {
        require(agencies[_agencyId].exists, "Agency does not exist");
        require(msg.sender == agencies[_agencyId].head, "Only the agency head can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Register a government agency with initial budget
    function registerAgency(string memory _name, address _head, uint256 _initialFunds) public onlyAdmin {
        bytes32 agencyId = keccak256(abi.encodePacked(_name, _head));
        require(!agencies[agencyId].exists, "Agency already exists");

        agencies[agencyId] = GovernmentAgency({
            name: _name,
            head: _head,
            allocatedFunds: _initialFunds,
            spentFunds: 0,
            exists: true
        });
    }

    /// @notice Allocate additional funds to an agency
    function allocateFunds(bytes32 _agencyId, uint256 _amount) public onlyAdmin {
        require(agencies[_agencyId].exists, "Agency does not exist");
        
        agencies[_agencyId].allocatedFunds += _amount;

        emit FundsAllocated(_agencyId, _amount);
    }

    /// @notice Spend funds from an agency's budget
    function spendFunds(bytes32 _agencyId, uint256 _amount) public onlyAgencyHead(_agencyId) {
        require(agencies[_agencyId].allocatedFunds >= agencies[_agencyId].spentFunds + _amount, "Insufficient funds");

        agencies[_agencyId].spentFunds += _amount;

        emit FundsSpent(_agencyId, _amount);
    }

    /// @notice Transfer funds between agencies
    function transferFunds(bytes32 _fromAgencyId, bytes32 _toAgencyId, uint256 _amount) public onlyAdmin {
        require(agencies[_fromAgencyId].exists, "Source agency does not exist");
        require(agencies[_toAgencyId].exists, "Target agency does not exist");
        require(agencies[_fromAgencyId].allocatedFunds >= agencies[_fromAgencyId].spentFunds + _amount, "Insufficient funds in source agency");

        agencies[_fromAgencyId].spentFunds += _amount;
        agencies[_toAgencyId].allocatedFunds += _amount;

        emit FundsTransferred(_fromAgencyId, _toAgencyId, _amount);
    }

    /// @notice Get agency financial details
    function getAgencyFunds(bytes32 _agencyId) public view returns (uint256 allocated, uint256 spent) {
        require(agencies[_agencyId].exists, "Agency does not exist");
        return (agencies[_agencyId].allocatedFunds, agencies[_agencyId].spentFunds);
    }
}
