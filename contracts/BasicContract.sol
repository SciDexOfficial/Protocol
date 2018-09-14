pragma solidity ^0.4.23;


import "./BasicContractPrivate.sol";

contract BasicContract  is BasicContractPrivate {

    address[] private admins;
    address[] private decliners;

    mapping (uint => uint) private confirmationStatus;
    uint minimumConfirmationsCount = 1;

    uint confirmationsCount = 0;
    
    constructor() public payable {
        setPaymentInfo();
    }

    function setAdmins() private {
        admins.push(0x0000000000000000000000000000000000000000);
    }
    function setDecliners() private {
        decliners.push(0x0000000000000000000000000000000000000000);
    }
    function getAdmins() public view returns(address[] memory) {
        return admins;
    }
    function getDecliners() public view returns(address[] memory) {
        return decliners;
    }

    function setPaymentInfo() internal {
        //set list of users who will get ethers
        //when contract will confirme
        payToUsers.push(0x0000000000000000000000000000000000000000);
        payToUsersAmount.push(0.1 ether);
    }

    function getPaymentInfo() public view returns(address[] memory, uint[] memory) {
        return (payToUsers, payToUsersAmount);
    }

    function sendConfirmation() public {
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] != msg.sender) {
                continue;
            }
            //checking if this user have already confiremed this contract
            require(confirmationStatus[i] == 0);
            
            confirmationStatus[i] = 1;
            confirmationsCount++;
            
            //
            WizardManager(managerAddress).userConfirmedContract(msg.sender);
            //when contract get minimum confirmations it will be confirmed
            if (confirmationsCount >= minimumConfirmationsCount) {
                confirmContract();
            }
        }
    }

    function cancel() public {
        for (uint i = 0; i < decliners.length; i++) {
            if (decliners[i] == msg.sender) {
                WizardManager(managerAddress).contractCanceled();
                selfdestruct(owner);
            }
        }
    }
}