pragma solidity ^0.4.23;

import "./WizardManager.sol";
import "./BasicContractInterface.sol";
import "./Ownable.sol";

contract BasicContract is Ownable, BasicContractInterface {

    address private managerAddress = 0x27Ccd3b2DD09491D9cB9B33c34DA7E292fF1D3c7;

    address[] private admins;
    mapping (uint => uint) private confirmationStatus;
    uint minimumConfirmationsCount = 1;

    uint confirmationsCount = 0;
    // uint cancelationsCount;
    bool contractConfirmationStatus = false;

    uint createAt;

    string rule = "";
    string contractType = "";

    address[] private payToUsers;
    uint[] private payToUsersAmount;

    constructor() public payable {
        createAt = now;
        //set all users who will get payment 
        payToUsers.push(0x0000000000000000000000000000000000000000);
        payToUsersAmount.push(0.1 ether);

        //set wizard manager contract address
        //send data and fee to the manager contract
        
        WizardManager(managerAddress).createdNewContract.value(msg.value)(contractType, rule);
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

    function confirmContract() private {
        //check that contract wasn't confirmed early
        require(contractConfirmationStatus == false);
        contractConfirmationStatus = true;
        ///pay money
        pay();
        //tell manager about contract confirmation
        WizardManager(managerAddress).contractConfirmed();
    }

    function cancel() public {
        require(((msg.sender == managerAddress) || (msg.sender == owner)));
        WizardManager(managerAddress).contractCanceled();
        selfdestruct(owner);
    }

    function pay() private {
        for (uint i = 0; i < payToUsers.length; i++) {
            payToUsers[i].transfer(payToUsersAmount[i]);
        }
    }
}