pragma solidity ^0.5.9;

contract RegistryContract {

    address owner;
    address[] contracts;
    address[] recoveryContacts;

    modifier onlyOwner(){
        if (msg.sender == owner) _;
    }
    modifier onlyRecoveryContacts(){
        for(uint i = 0; i < recoveryContacts.length; i++)
            if(recoveryContacts[i] == msg.sender) _;
    }
    modifier onlyOwnerOrRecoveryContacts(){
        if (msg.sender == owner) _;
        for(uint i = 0; i < recoveryContacts.length; i++)
            if(recoveryContacts[i] == msg.sender) _;
    }

    constructor(address _contractAddress) public {
        owner = msg.sender;
        if (_contractAddress != address(0)){
            contracts.push(_contractAddress);
        }
    }

    function getContracts() public view onlyOwnerOrRecoveryContacts returns (address[] memory _contracts){
        _contracts = contracts;
    }

    function getRecoveryContacts() public view onlyOwner returns (address[] memory _recoveryContacts){
        _recoveryContacts = recoveryContacts;
    }

    function addContract(address _contractAddress) public onlyOwner {
        if (_contractAddress != address(0)){
            contracts.push(_contractAddress);
        }
    }

    function removeContract(uint index) public onlyOwner {
        if (index >= contracts.length) return;

        for (uint i = index; i<contracts.length-1; i++){
            contracts[i] = contracts[i+1];
        }
        contracts.length--;
    }

    function changeOwner(address _ownerAddress) public onlyRecoveryContacts {
        if (_ownerAddress != address(0)){
            owner = _ownerAddress;
        }
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
}