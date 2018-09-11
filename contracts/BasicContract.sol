pragma solidity ^0.4.23;

import "./Ownable.sol";
import "./WizardManager.sol";

contract BasicContract is Ownable {

    address private managerAddress = 0x353bbcf7303Bd5CfA3a386170d32c12DD3844c4c;

    address[] private admins;
    mapping (uint => uint) private confirmationStatus;
    uint minimumConfirmationsCount = 1;
    uint minimumCancelationsCount = 1;

    uint confirmationsCount;
    // uint cancelationsCount;
    bool contractConfirmationStatus = false;

    constructor() public payable {
        //set wizard manager contract address
        //send data and fee to the manager contract
        WizardManager(managerAddress).createdNewContract.value(msg.value)("type", "data");

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
        require(contractConfirmationStatus == false);
        contractConfirmationStatus = true;
        ///pay money
    }

    function cancel() public onlyOwner {
        selfdestruct(owner);
    }
}