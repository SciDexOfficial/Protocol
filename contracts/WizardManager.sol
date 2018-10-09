pragma solidity ^0.4.23;

import "./Ownable.sol";
import "./BasicContractInterface.sol";

//this contract will manage all new contracts 
//generated from the website
contract WizardManager is Ownable {

    event createdNewContractEvent(address contractAddress, address owner, address payToUser, uint[] payAmounts, string rules);
    event contractRuleConfirmedEvent(address contractAddress, uint ruleIndex, string params);
    event contractCanceledEvent(address contractAddress);
    event contractCancelingEvent(address contractAddress, address cancelingBy);
    event sentPaymentToUserEvent(address contractAddress, uint amount, address user);

    function createdNewContract(address owner, address payToUser, uint[] payAmounts, string rules) public payable {
        emit createdNewContractEvent(msg.sender, owner, payToUser, payAmounts, rules);
    }

    function sentPaymentToUser(uint amount, address user) public {
        emit sentPaymentToUserEvent(msg.sender, amount, user);
    }

    function contractCanceled() public {
        emit contractCanceledEvent(msg.sender);
    }

    function contractCanceling(address cancelingBy) public {
        emit contractCancelingEvent(msg.sender, cancelingBy);
    }
    
    function contractRuleConfirmed(uint ruleIndex, string params) public {
        emit contractRuleConfirmedEvent(msg.sender, ruleIndex, params);
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }
    function cancelContract(address contractAddress) public onlyOwner {
        BasicContractInterface(contractAddress).cancel();
    }
    function setCompletionRate(address contractAddress, uint rate) public onlyOwner {
        BasicContractInterface(contractAddress).setCompletionRate(rate);
    }
}