// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// This contract allows citizens to create petitions, gather support, and escalate issues to the government.
contract GoverDuePetition {
    address public admin;  // Contract administrator

    uint256 public minSupportRequirement = 100;  // Minimum support required for review
    uint256 public petitionExpiryTime = 30 days; // Expiry time for petitions (in seconds)
    uint256 public petitionFee = 0.01 ether;     // Fee required to create a petition

    struct Petition {
        string title;         // Petition title
        string description;   // Petition details
        address creator;      // Petition creator
        uint256 supportCount; // Number of citizens supporting the petition
        uint256 createdAt;    // Timestamp of petition creation
        bool reviewed;        // Whether the petition has been reviewed
        bool exists;          // Whether the petition exists
    }

    mapping(bytes32 => Petition) public petitions;
    mapping(bytes32 => mapping(address => bool)) public hasSupported; // Tracks supporters for each petition

    event PetitionCreated(bytes32 indexed petitionId, string title, address creator);
    event PetitionSupported(bytes32 indexed petitionId, address supporter);
    event PetitionReviewed(bytes32 indexed petitionId, bool approved);
    event PetitionRefunded(bytes32 indexed petitionId, address recipient);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyPetitionCreator(bytes32 _petitionId) {
        require(petitions[_petitionId].exists, "Petition does not exist");
        require(msg.sender == petitions[_petitionId].creator, "Only the creator can perform this action");
        _;
    }

    /// @notice Contract constructor (only sets admin)
    constructor() {
        admin = msg.sender;  // Set the contract administrator
    }

    /// @notice Create a new petition (requires a fee)
    /// @param _title The title of the petition
    /// @param _description The description of the petition
    function createPetition(string memory _title, string memory _description) public payable {
        require(msg.value == petitionFee, "Incorrect petition fee");

        bytes32 petitionId = keccak256(abi.encodePacked(_title, msg.sender, block.timestamp));
        require(!petitions[petitionId].exists, "Petition already exists");

        petitions[petitionId] = Petition({
            title: _title,
            description: _description,
            creator: msg.sender,
            supportCount: 0,
            createdAt: block.timestamp,
            reviewed: false,
            exists: true
        });

        emit PetitionCreated(petitionId, _title, msg.sender);
    }

    /// @notice Support an existing petition (only before expiry)
    /// @param _petitionId The ID of the petition to support
    function supportPetition(bytes32 _petitionId) public {
        require(petitions[_petitionId].exists, "Petition does not exist");
        require(!hasSupported[_petitionId][msg.sender], "You have already supported this petition");
        require(block.timestamp <= petitions[_petitionId].createdAt + petitionExpiryTime, "Petition has expired");

        petitions[_petitionId].supportCount++;
        hasSupported[_petitionId][msg.sender] = true;

        emit PetitionSupported(_petitionId, msg.sender);
    }

    /// @notice Review a petition (only if it meets the minimum support requirement)
    /// @param _petitionId The ID of the petition to review
    /// @param _approved Whether the petition is approved or rejected
    function reviewPetition(bytes32 _petitionId, bool _approved) public onlyAdmin {
        require(petitions[_petitionId].exists, "Petition does not exist");
        require(!petitions[_petitionId].reviewed, "Petition has already been reviewed");
        require(petitions[_petitionId].supportCount >= minSupportRequirement, "Petition does not have enough support");

        petitions[_petitionId].reviewed = true;

        emit PetitionReviewed(_petitionId, _approved);
    }

    /// @notice Refund the petition fee if it didn't reach enough support before expiry
    /// @param _petitionId The ID of the petition to refund
    function refundPetitionFee(bytes32 _petitionId) public onlyPetitionCreator(_petitionId) {
        require(petitions[_petitionId].exists, "Petition does not exist");
        require(block.timestamp > petitions[_petitionId].createdAt + petitionExpiryTime, "Petition has not expired yet");
        require(petitions[_petitionId].supportCount < minSupportRequirement, "Petition reached support threshold");

        uint256 refundAmount = petitionFee;
        address creator = petitions[_petitionId].creator;

        delete petitions[_petitionId]; // Remove petition from storage

        payable(creator).transfer(refundAmount);
        emit PetitionRefunded(_petitionId, creator);
    }

    /// @notice Get petition details
    /// @param _petitionId The ID of the petition to retrieve
    /// @return title The title of the petition
    /// @return description The description of the petition
    /// @return creator The address of the petition creator
    /// @return supportCount The number of supporters
    /// @return createdAt The timestamp when the petition was created
    /// @return reviewed Whether the petition has been reviewed
    /// @return exists Whether the petition exists
    function getPetition(bytes32 _petitionId) public view returns (
        string memory title, 
        string memory description, 
        address creator, 
        uint256 supportCount, 
        uint256 createdAt, 
        bool reviewed, 
        bool exists
    ) {
        require(petitions[_petitionId].exists, "Petition does not exist");

        Petition memory petition = petitions[_petitionId];
        return (
            petition.title, 
            petition.description, 
            petition.creator, 
            petition.supportCount, 
            petition.createdAt, 
            petition.reviewed, 
            petition.exists
        );
    }
}
