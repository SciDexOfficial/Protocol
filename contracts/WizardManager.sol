pragma solidity ^0.4.23;

import "./Ownable.sol";
//this contract will manage all new contracts 
//generated from the website
contract WizardManager is Ownable {

    event createdNewContractEvent(address contractAddress, string contractType, string data);
    
    function createdNewContract(string contractType, string data) public payable {
        emit createdNewContractEvent(msg.sender, contractType, data);
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }
}