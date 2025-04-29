// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Academic Credential Verification
 * @dev Smart contract for issuing and verifying academic credentials
 */
contract AcademicCredentialVerification {
    // Structure to store credential information
    struct Credential {
        string studentName;
        string credentialHash;      // IPFS hash or other reference to detailed credential data
        uint256 issueDate;
        bool isValid;
        string institutionName;
    }
    
    // Credential mapping: credentialId => Credential
    mapping(bytes32 => Credential) public credentials;
    
    // Mapping to track authorized educational institutions
    mapping(address => bool) public authorizedInstitutions;
    
    // Contract owner
    address public owner;
    
    // Events
    event CredentialIssued(bytes32 indexed credentialId, string studentName, address indexed institution);
    event CredentialRevoked(bytes32 indexed credentialId, string reason);
    event InstitutionAuthorized(address institution);
    event InstitutionDeauthorized(address institution);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyAuthorizedInstitution() {
        require(authorizedInstitutions[msg.sender], "Only authorized institutions can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Authorize an educational institution to issue credentials
     * @param institution Address of the institution to authorize
     */
    function authorizeInstitution(address institution) external onlyOwner {
        authorizedInstitutions[institution] = true;
        emit InstitutionAuthorized(institution);
    }
    
    /**
     * @dev Issue a new academic credential
     * @param studentName Name of the student
     * @param credentialHash IPFS hash or other reference to detailed credential data
     * @param institutionName Name of the issuing institution
     * @return credentialId Unique identifier for the issued credential
     */
    function issueCredential(
        string memory studentName,
        string memory credentialHash,
        string memory institutionName
    ) external onlyAuthorizedInstitution returns (bytes32 credentialId) {
        // Generate a unique credential ID based on input data
        credentialId = keccak256(abi.encodePacked(studentName, credentialHash, block.timestamp, msg.sender));
        
        // Create and store the credential
        credentials[credentialId] = Credential({
            studentName: studentName,
            credentialHash: credentialHash,
            issueDate: block.timestamp,
            isValid: true,
            institutionName: institutionName
        });
        
        emit CredentialIssued(credentialId, studentName, msg.sender);
        return credentialId;
    }
    
  
    function verifyCredential(bytes32 credentialId) 
        external 
        view 
        returns (
            bool isValid,
            string memory studentName,
            uint256 issueDate,
            string memory institutionName
        ) 
    {
        Credential memory credential = credentials[credentialId];
        return (
            credential.isValid,
            credential.studentName,
            credential.issueDate,
            credential.institutionName
        );
    }
}
