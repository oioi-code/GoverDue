// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// This contract enables citizens to participate in elections, referendums, and governance decisions.
contract GoverDueVoting {
    address public admin;  // Contract administrator

    enum VoteType { Election, Referendum, PolicyVote }
    enum VoteStatus { Ongoing, Completed }

    struct Vote {
        string title;          // Title of the vote
        string description;    // Description of the voting subject
        VoteType voteType;     // Type of vote (Election, Referendum, Policy)
        VoteStatus status;     // Voting status
        uint256 deadline;      // Voting deadline (timestamp)
        bool exists;           // Whether the vote exists
    }

    struct Candidate {
        string name;           // Candidate name
        uint256 voteCount;     // Total votes received
    }

    mapping(bytes32 => Vote) public votes;
    mapping(bytes32 => Candidate[]) public candidates;
    mapping(bytes32 => mapping(address => bool)) public hasVoted; // Tracks votes for each election

    event VoteCreated(bytes32 indexed voteId, string title, VoteType voteType, uint256 deadline);
    event VoteCast(bytes32 indexed voteId, address voter, uint256 candidateIndex);
    event VoteConcluded(bytes32 indexed voteId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyBeforeDeadline(bytes32 _voteId) {
        require(block.timestamp < votes[_voteId].deadline, "Voting period has ended");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Create a new vote (election, referendum, or policy vote)
    function createVote(string memory _title, string memory _description, VoteType _voteType, uint256 _duration) public onlyAdmin {
        bytes32 voteId = keccak256(abi.encodePacked(_title, block.timestamp));
        require(!votes[voteId].exists, "Vote already exists");

        votes[voteId] = Vote({
            title: _title,
            description: _description,
            voteType: _voteType,
            status: VoteStatus.Ongoing,
            deadline: block.timestamp + _duration,
            exists: true
        });

        emit VoteCreated(voteId, _title, _voteType, votes[voteId].deadline);
    }

    /// @notice Add a candidate to an election
    function addCandidate(bytes32 _voteId, string memory _name) public onlyAdmin {
        require(votes[_voteId].exists, "Vote does not exist");
        require(votes[_voteId].voteType == VoteType.Election, "Only elections can have candidates");

        candidates[_voteId].push(Candidate({
            name: _name,
            voteCount: 0
        }));
    }

    /// @notice Cast a vote
    function castVote(bytes32 _voteId, uint256 _candidateIndex) public onlyBeforeDeadline(_voteId) {
        require(votes[_voteId].exists, "Vote does not exist");
        require(!hasVoted[_voteId][msg.sender], "You have already voted");

        hasVoted[_voteId][msg.sender] = true;

        if (votes[_voteId].voteType == VoteType.Election) {
            require(_candidateIndex < candidates[_voteId].length, "Invalid candidate index");
            candidates[_voteId][_candidateIndex].voteCount++; //voteCount also changes accordingly
        }

        emit VoteCast(_voteId, msg.sender, _candidateIndex);
    }

    /// @notice Conclude a vote
    function concludeVote(bytes32 _voteId) public onlyAdmin {
        require(votes[_voteId].exists, "Vote does not exist");
        require(block.timestamp >= votes[_voteId].deadline, "Voting period is not over yet");

        votes[_voteId].status = VoteStatus.Completed;

        emit VoteConcluded(_voteId);
    }

    /// @notice Get vote details
    function getVote(bytes32 _voteId) public view returns (
        string memory title,
        string memory description,
        VoteType voteType,
        VoteStatus status,
        uint256 deadline,
        bool exists
    ) {
        require(votes[_voteId].exists, "Vote does not exist");

        Vote memory vote = votes[_voteId];
        return (vote.title, vote.description, vote.voteType, vote.status, vote.deadline, vote.exists);
    }

    /// @notice Get candidate details for an election
    function getCandidates(bytes32 _voteId) public view returns (Candidate[] memory) {
        require(votes[_voteId].exists, "Vote does not exist");
        require(votes[_voteId].voteType == VoteType.Election, "Only elections have candidates");

        return candidates[_voteId];
    }
}
