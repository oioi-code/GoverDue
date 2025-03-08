// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// GoverDueContracts - Government Contract Management System
/// @notice This contract enables government agencies to create contracts, assign contractors, track progress, and release payments.
contract GoverDueContracts {
    address public admin;  // Contract administrator

    enum ContractStatus { Created, InProgress, Completed, Cancelled }

    struct GovContract {
        string title;           // Contract title
        string description;     // Contract details
        address agency;         // Government agency responsible for the contract
        address contractor;     // Assigned contractor (wallet address)
        uint256 budget;         // Total budget for the contract
        uint256 releasedFunds;  // Funds already released
        ContractStatus status;  // Current status of the contract
        bool exists;            // Whether the contract exists
    }

    mapping(bytes32 => GovContract) public contracts;

    event ContractCreated(bytes32 indexed contractId, string title, address agency, uint256 budget);
    event ContractorAssigned(bytes32 indexed contractId, address contractor);
    event ContractUpdated(bytes32 indexed contractId, ContractStatus status);
    event FundsReleased(bytes32 indexed contractId, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyAgency(bytes32 _contractId) {
        require(contracts[_contractId].exists, "Contract does not exist");
        require(msg.sender == contracts[_contractId].agency, "Only the responsible agency can perform this action");
        _;
    }

    modifier onlyContractor(bytes32 _contractId) {
        require(contracts[_contractId].exists, "Contract does not exist");
        require(msg.sender == contracts[_contractId].contractor, "Only the assigned contractor can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Create a new government contract
    function createContract(string memory _title, string memory _description, address _agency, uint256 _budget) public onlyAdmin {
        bytes32 contractId = keccak256(abi.encodePacked(_title, _agency, block.timestamp));
        require(!contracts[contractId].exists, "Contract already exists");

        contracts[contractId] = GovContract({
            title: _title,
            description: _description,
            agency: _agency,
            contractor: address(0),
            budget: _budget,
            releasedFunds: 0,
            status: ContractStatus.Created,
            exists: true
        });

        emit ContractCreated(contractId, _title, _agency, _budget);
    }

    /// @notice Assign a contractor to a contract
    function assignContractor(bytes32 _contractId, address _contractor) public onlyAgency(_contractId) {
        require(contracts[_contractId].contractor == address(0), "Contractor already assigned");

        contracts[_contractId].contractor = _contractor;

        emit ContractorAssigned(_contractId, _contractor);
    }

    /// @notice Update contract status
    function updateContractStatus(bytes32 _contractId, ContractStatus _status) public onlyAgency(_contractId) {
        contracts[_contractId].status = _status;

        emit ContractUpdated(_contractId, _status);
    }

    /// @notice Release funds to the contractor
    function releaseFunds(bytes32 _contractId, uint256 _amount) public onlyAgency(_contractId) {
        require(contracts[_contractId].contractor != address(0), "Contractor not assigned");
        require(contracts[_contractId].budget >= contracts[_contractId].releasedFunds + _amount, "Insufficient budget");

        contracts[_contractId].releasedFunds += _amount;

        emit FundsReleased(_contractId, _amount);
    }

    /// @notice Get contract details
    function getContract(bytes32 _contractId) public view returns (
        string memory title,
        string memory description,
        address agency,
        address contractor,
        uint256 budget,
        uint256 releasedFunds,
        ContractStatus status,
        bool exists
    ) {
        require(contracts[_contractId].exists, "Contract does not exist");

        GovContract memory govContract = contracts[_contractId];
        return (
            govContract.title,
            govContract.description,
            govContract.agency,
            govContract.contractor,
            govContract.budget,
            govContract.releasedFunds,
            govContract.status,
            govContract.exists
        );
    }
}
