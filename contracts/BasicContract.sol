pragma solidity ^0.4.23;


import "./BasicContractPrivate.sol";

contract BasicContract  is BasicContractPrivate {

    address[] private admins;
    mapping (uint => uint) private confirmationStatus;
    uint minimumConfirmationsCount = 1;

    uint confirmationsCount = 0;
    constructor() public payable {
        setPaymentInfo();
    }
    function setPaymentInfo() internal {
        //set list of users who will get ethers
        //when contract will confirme
        payToUsers.push(0x0000000000000000000000000000000000000000);
        payToUsersAmount.push(0.1 ether);
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
            //when contract get minimum confirmations it will be confirmed
            if (confirmationsCount >= minimumConfirmationsCount) {
                confirmContract();
            }
        }
    }

    function cancel() public {
        //only owner or oracle contract could cancel this contract
        require(((msg.sender == managerAddress) || (msg.sender == owner)));
        WizardManager(managerAddress).contractCanceled();
        selfdestruct(owner);
    }
}