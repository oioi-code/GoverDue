// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// This contract enables citizens to create and participate in surveys.
contract GoverDueSurvey {
    address public admin; // Contract administrator

    // Survey structure to store survey details and responses
    struct Survey {
        string title;       // Title of the survey
        string description; // Description of the survey
        uint256 deadline;   // Deadline for responses (timestamp)
        bool exists;        // Flag to check if survey exists
        mapping(uint256 => uint256) responses; // Choice index => response count
    }

    // Mapping to store surveys by their unique ID
    mapping(bytes32 => Survey) public surveys;
    // Mapping to track which addresses have responded to which surveys
    mapping(bytes32 => mapping(address => bool)) public hasResponded;

    // Event emitted when a new survey is created
    event SurveyCreated(bytes32 indexed surveyId, string title, uint256 deadline);
    // Event emitted when someone responds to a survey
    event SurveyResponded(bytes32 indexed surveyId, address respondent, uint256 choice);

    // Modifier to restrict access to admin only
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    // Modifier to ensure actions only happen before survey deadline
    modifier onlyBeforeDeadline(bytes32 _surveyId) {
        require(block.timestamp < surveys[_surveyId].deadline, "Survey has ended");
        _;
    }

    // Constructor sets the contract deployer as admin
    constructor() {
        admin = msg.sender;
    }

    // Function to create a new survey (admin only)
    function createSurvey(string memory _title, string memory _description, uint256 _duration) public onlyAdmin {
        // Generate unique survey ID using title and current timestamp
        bytes32 surveyId = keccak256(abi.encodePacked(_title, block.timestamp));
        require(!surveys[surveyId].exists, "Survey already exists");

        // Create new survey and store in mapping
        Survey storage survey = surveys[surveyId];
        survey.title = _title;
        survey.description = _description;
        survey.deadline = block.timestamp + _duration; // Calculate deadline
        survey.exists = true;

        // Emit event for survey creation
        emit SurveyCreated(surveyId, _title, survey.deadline);
    }

    // Function to respond to a survey
    function respondToSurvey(bytes32 _surveyId, uint256 _choice) public onlyBeforeDeadline(_surveyId) {
        require(surveys[_surveyId].exists, "Survey does not exist");
        require(!hasResponded[_surveyId][msg.sender], "You have already responded");

        // Mark sender as having responded
        hasResponded[_surveyId][msg.sender] = true;
        // Increment response count for the chosen option
        surveys[_surveyId].responses[_choice]++;

        // Emit event for survey response
        emit SurveyResponded(_surveyId, msg.sender, _choice);
    }

    // Function to get results for a specific choice in a survey
    function getSurveyResults(bytes32 _surveyId, uint256 _choice) public view returns (uint256) {
        require(surveys[_surveyId].exists, "Survey does not exist");
        return surveys[_surveyId].responses[_choice];
    }
}
