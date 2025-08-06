// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./GoverDue.sol";
import "./GoverDueFunds.sol";
import "./GoverDueIdentity.sol";
import "./GoverDuePetition.sol";
import "./GoverDueContracts.sol";
import "./GoverDueVoting.sol";

/// This contract deploys all GoverDue-related smart contracts and stores their addresses.
contract GoverDueDeployer {
    address public admin;

    GoverDue public goverDue;
    GoverDueFunds public goverDueFunds;
    GoverDueIdentity public goverDueIdentity;
    GoverDuePetition public goverDuePetition;
    GoverDueContracts public goverDueContracts;
    GoverDueVoting public goverDueVoting;

    event ContractsDeployed(
        address indexed goverDue,
        address indexed goverDueFunds,
        address indexed goverDueIdentity,
        address goverDuePetition,
        address goverDueContracts,
        address goverDueVoting
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;

        // Deploy the core GoverDue contract
        goverDue = new GoverDue();

        // Deploy additional modules
        goverDueFunds = new GoverDueFunds();
        goverDueIdentity = new GoverDueIdentity();
        goverDuePetition = new GoverDuePetition();
        goverDueContracts = new GoverDueContracts();
        goverDueVoting = new GoverDueVoting();

        emit ContractsDeployed(
            address(goverDue),
            address(goverDueFunds),
            address(goverDueIdentity),
            address(goverDuePetition),
            address(goverDueContracts),
            address(goverDueVoting)
        );
    }

    /// @notice Get the deployed contract addresses
    function getContracts() public view returns (
        address, address, address, address, address, address
    ) {
        return (
            address(goverDue),
            address(goverDueFunds),
            address(goverDueIdentity),
            address(goverDuePetition),
            address(goverDueContracts),
            address(goverDueVoting)
        );
    }
}
