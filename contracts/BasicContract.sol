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
        ///
        payToUsers.push(0x0000000000000000000000000000000000000000);
        payToUsersAmount.push(0.1 ether);
    }

    function sendConfirmation() public {
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] != msg.sender) {
                continue;
            }

            require(confirmationStatus[i] == 0);
            
            confirmationStatus[i] = 1;
            confirmationsCount++;
            if (confirmationsCount >= minimumConfirmationsCount) {
                confirmContract();
            }
        }
    }

    function cancel() public {
        require(((msg.sender == managerAddress) || (msg.sender == owner)));
        WizardManager(managerAddress).contractCanceled();
        selfdestruct(owner);
    }
}