// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GoverDuePetition - Decentralized Petition System
/// @notice This contract allows citizens to create petitions, gather support, and escalate issues to the government.
contract GoverDuePetition {
    address public admin;  // Contract administrator

    struct Petition {
        string title;         // Petition title
        string description;   // Petition details
        address creator;      // Petition creator
        uint256 supportCount; // Number of citizens supporting the petition
        bool reviewed;        // Whether the petition has been reviewed
        bool exists;          // Whether the petition exists
    }

    mapping(bytes32 => Petition) public petitions;
    mapping(bytes32 => mapping(address => bool)) public hasSupported; // Tracks supporters for each petition

    event PetitionCreated(bytes32 indexed petitionId, string title, address creator);
    event PetitionSupported(bytes32 indexed petitionId, address supporter);
    event PetitionReviewed(bytes32 indexed petitionId, bool approved);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyPetitionCreator(bytes32 _petitionId) {
        require(petitions[_petitionId].exists, "Petition does not exist");
        require(msg.sender == petitions[_petitionId].creator, "Only the creator can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Create a new petition
    function createPetition(string memory _title, string memory _description) public {
        bytes32 petitionId = keccak256(abi.encodePacked(_title, msg.sender, block.timestamp));
        require(!petitions[petitionId].exists, "Petition already exists");

        petitions[petitionId] = Petition({
            title: _title,
            description: _description,
            creator: msg.sender,
            supportCount: 0,
            reviewed: false,
            exists: true
        });

        emit PetitionCreated(petitionId, _title, msg.sender);
    }

    /// @notice Support an existing petition
    function supportPetition(bytes32 _petitionId) public {
        require(petitions[_petitionId].exists, "Petition does not exist");
        require(!hasSupported[_petitionId][msg.sender], "You have already supported this petition");

        petitions[_petitionId].supportCount++;
        hasSupported[_petitionId][msg.sender] = true;

        emit PetitionSupported(_petitionId, msg.sender);
    }

    /// @notice Mark a petition as reviewed
    function reviewPetition(bytes32 _petitionId, bool _approved) public onlyAdmin {
        require(petitions[_petitionId].exists, "Petition does not exist");
        require(!petitions[_petitionId].reviewed, "Petition has already been reviewed");

        petitions[_petitionId].reviewed = true;

        emit PetitionReviewed(_petitionId, _approved);
    }

    /// @notice Get petition details
    function getPetition(bytes32 _petitionId) public view returns (string memory title, string memory description, address creator, uint256 supportCount, bool reviewed, bool exists) {
        require(petitions[_petitionId].exists, "Petition does not exist");

        Petition memory petition = petitions[_petitionId];
        return (petition.title, petition.description, petition.creator, petition.supportCount, petition.reviewed, petition.exists);
    }
}
