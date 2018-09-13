pragma solidity ^0.4.23;

import "./Ownable.sol";
import "./BasicContractInterface.sol";

//this contract will manage all new contracts 
//generated from the website
contract WizardManager is Ownable {

    event createdNewContractEvent(address contractAddress, string contractType, string data);
    event contractConfirmedEvent(address contractAddress);
    event contractCanceledEvent(address contractAddress);
    event userConfirmedContractEvent(address user, address contracAddress);

    function createdNewContract(string contractType, string data) public payable {
        emit createdNewContractEvent(msg.sender, contractType, data);
    }

    function contractCanceled() public {
        emit contractCanceledEvent(msg.sender);
    }

    function contractConfirmed() public {
        emit contractConfirmedEvent(msg.sender);
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }
    function cancelContract(address contractAddress) public onlyOwner {
        BasicContractInterface(contractAddress).cancel();
    }
    function userConfirmedContract(address user) public {
        emit userConfirmedContractEvent(user, msg.sender);
    }
}