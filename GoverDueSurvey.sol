// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// This contract enables citizens to create and participate in surveys.
contract GoverDueSurvey {
    address public admin; // Contract administrator

    struct Survey {
        string title;
        string description;
        uint256 deadline;
        bool exists;
        mapping(uint256 => uint256) responses; // Choice index => response count
    }

    mapping(bytes32 => Survey) public surveys;
    mapping(bytes32 => mapping(address => bool)) public hasResponded;

    event SurveyCreated(bytes32 indexed surveyId, string title, uint256 deadline);
    event SurveyResponded(bytes32 indexed surveyId, address respondent, uint256 choice);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyBeforeDeadline(bytes32 _surveyId) {
        require(block.timestamp < surveys[_surveyId].deadline, "Survey has ended");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createSurvey(string memory _title, string memory _description, uint256 _duration) public onlyAdmin {
        bytes32 surveyId = keccak256(abi.encodePacked(_title, block.timestamp));
        require(!surveys[surveyId].exists, "Survey already exists");

        Survey storage survey = surveys[surveyId];
        survey.title = _title;
        survey.description = _description;
        survey.deadline = block.timestamp + _duration;
        survey.exists = true;

        emit SurveyCreated(surveyId, _title, survey.deadline);
    }

    function respondToSurvey(bytes32 _surveyId, uint256 _choice) public onlyBeforeDeadline(_surveyId) {
        require(surveys[_surveyId].exists, "Survey does not exist");
        require(!hasResponded[_surveyId][msg.sender], "You have already responded");

        hasResponded[_surveyId][msg.sender] = true;
        surveys[_surveyId].responses[_choice]++;

        emit SurveyResponded(_surveyId, msg.sender, _choice);
    }

    function getSurveyResults(bytes32 _surveyId, uint256 _choice) public view returns (uint256) {
        require(surveys[_surveyId].exists, "Survey does not exist");
        return surveys[_surveyId].responses[_choice];
    }
}
