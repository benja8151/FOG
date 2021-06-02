pragma solidity ^0.5.9;

contract IdentityContract {

    address owner; // public key;
    string ipfs_hash;
    address[] recoveryContacts;
    address verifier;
    address[] services;
    bool verified;
    uint[] reputationRankings;

    modifier onlyOwner(){
        if (msg.sender == owner) _;
    }
    modifier onlyVerifier(){
        if (msg.sender == verifier) _;
    }
    modifier onlyOwnerVerifierServices(){
        if (msg.sender == owner || msg.sender == verifier) _;
        for(uint i = 0; i < services.length; i++)
            if(services[i] == msg.sender) _;
    }
    modifier onlyRecoveryContacts(){
        for(uint i = 0; i < recoveryContacts.length; i++)
            if(recoveryContacts[i] == msg.sender) _;
    }
    modifier onlyServices(){
        for(uint i = 0; i < services.length; i++)
            if(services[i] == msg.sender) _;
    }
    
    constructor() public {
        owner = msg.sender;
        verified = false;
    }

    function setIPFSHash(string memory _ipfs_hash) public onlyOwner {
        ipfs_hash = _ipfs_hash;
    }

    function addRecoveryContact(address _contactAddress) public onlyOwner {
        if (_contactAddress != address(0)){
            recoveryContacts.push(_contactAddress);
        }
    }

    function removeRecoveryContact(uint index) public onlyOwner {
        if (index >= recoveryContacts.length) return;

        for (uint i = index; i<recoveryContacts.length-1; i++){
            recoveryContacts[i] = recoveryContacts[i+1];
        }
        recoveryContacts.length--;
    }

    function setVerifier(address _verifierAddress) public onlyOwner {
        if (_verifierAddress != address(0)){
            verifier = _verifierAddress;
        }
    }

    function verifyContract(bool _verified) public onlyVerifier {
        verified = _verified;
    }

    function addService(address _serviceAddress) public onlyOwner {
        if (_serviceAddress != address(0)){
            services.push(_serviceAddress);
        }
    }

    function removeService(uint index) public onlyOwner {
        if (index >= services.length) return;

        for (uint i = index; i<services.length-1; i++){
            services[i] = services[i+1];
        }
        services.length--;
    }

    function changeOwner(address _ownerAddress) public onlyRecoveryContacts {
        if (_ownerAddress != address(0)){
            owner = _ownerAddress;
        }
    }

    function getDetails() public view onlyOwnerVerifierServices returns (
        address _owner, 
        string memory _ipfs_hash,
        address[] memory _recoveryContacts,
        address _verifier,
        address[] memory _services,
        bool _verified,
        uint[] memory _reputationRankings
    ){
        _owner = owner;
        _ipfs_hash = ipfs_hash;
        _recoveryContacts = recoveryContacts;
        _verifier = verifier;
        _services = services;
        _verified = verified;
        _reputationRankings = reputationRankings;
    }

    function addReputationRanking(uint ranking) public onlyServices {
        reputationRankings.push(ranking);
    }
}