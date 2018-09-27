pragma solidity ^0.4.23;

import "./Ownable.sol";
import "./SafeMath.sol";

contract WizardMainContract is Ownable {

    using SafeMath for uint;
    
    
    struct SubContract {
        string rule;
        address[] payToUsers;
        uint[] payAmounts;
        address owner;
    }

    //events
    event createdNewContractEvent(uint contractIndex, string rule);
    event contractConfirmedEvent(uint contractIndex);
    event contractCanceledEvent(uint contractIndex);
    event userConfirmedContractEvent(address user, uint contractIndex);

    mapping (uint => mapping (uint => uint)) private confirmationStatus;
    mapping(uint => uint) private confirmationsCount;
    SubContract[] private subcontracts;

    uint private serviceFee = 0.0 ether;
    
    mapping(uint => uint) private completionRate;
    
    mapping(uint => uint) private contractConfirmationStatus;
    
    //approve
    
    function setServiceFee(uint fee) public onlyOwner {
        serviceFee = fee;
    }

    function addContract(
        string rule,
        address[] payToUsers, 
        uint[] payAmounts) public payable returns(uint index) {
        uint payment = serviceFee;
        for (uint i = 0; i < payAmounts.length; i++) {
            payment = payment.add(payAmounts[i]);
        }
        require(payment <= msg.value);
        
        owner.transfer(serviceFee);
        if (msg.value > payment) {
            msg.sender.transfer(msg.value.sub(payment));
        }

        SubContract memory sc = SubContract(rule, payToUsers, payAmounts, msg.sender);
        index = subcontracts.push(sc) - 1;
        emit createdNewContractEvent(index, rule);
    }


    // function getAdmins(uint index) public view returns(address[] memory) {
    //     return subcontracts[index].admins;
    // }
    
    // function getDecliners(uint index) public view returns(address[] memory) {
    //     return subcontracts[index].decliners;
    // }

    function getPaymentInfo(uint index) public view returns(address[] memory, uint[] memory) {
        return (subcontracts[index].payToUsers, subcontracts[index].payAmounts);
    }

    function sendConfirmation(uint index) public onlyOwner {
        
        // address[] memory admins = subcontracts[index].admins;

        // for (uint i = 0; i < admins.length; i++) {
            // if (admins[i] != msg.sender) {
            //     continue;
            // }
            //checking if this user have already confiremed this contract
        // require(confirmationStatus[index][i] == 0);
            
        // confirmationStatus[index][i] = 1;
        // confirmationsCount[index]++;
            
            //
        emit userConfirmedContractEvent(msg.sender, index);
            //when contract get minimum confirmations it will be confirmed
            
        // if (confirmationsCount[index] >= subcontracts[index].minimumConfirmationsCount) {
        confirmContract(index);
        // }
    }

    // function getRule(uint index) public view returns(string memory) {
    //     return subcontracts[index].rule;
    // }

    function cancel(uint index) public onlyOwner {
    //     address[] memory decliners = subcontracts[index].decliners;

    //     for (uint i = 0; i < decliners.length; i++) {
    //         if (decliners[i] == msg.sender) {
        contractConfirmationStatus[index] = 2;
        emit contractCanceledEvent(index);
    //         }
    //     }
    }

    function confirmContract(uint index) private {
        //check that contract wasn't confirmed early
        require(contractConfirmationStatus[index] == 0);
        contractConfirmationStatus[index] = 1;
        ///pay money
        pay(index);
        //tell manager about contract confirmation
        emit contractConfirmedEvent(index);
    }
    
    function setCompletionRate(uint index, uint rate) public onlyOwner {
        completionRate[index] = rate;
    }

    function pay(uint index) private {
        //send ethers to all users from the list
        address[] memory payToUsers = subcontracts[index].payToUsers;
        uint[] memory amounts = subcontracts[index].payAmounts;

        for (uint i = 0; i < payToUsers.length; i++) {
            payToUsers[i].transfer(amounts[i].mul(completionRate[index]).div(10000));
        }
    }
}