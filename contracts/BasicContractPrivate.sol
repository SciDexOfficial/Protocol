pragma solidity ^0.4.23;

import "./WizardManager.sol";
import "./BasicContractInterface.sol";
import "./Ownable.sol";
import "./WizardManager.sol";

contract BasicContractPrivate is Ownable, BasicContractInterface {
    
    address internal managerAddress = 0x9f0ff1Ab4ee32D0CeD7109729dD466A223dbA2Db;

    uint createAt;
    uint constant serviceFee = 0.01 ether;

    bool contractConfirmationStatus = false;
    //set rule
    string constant rule = "$RULE_STRING";
    //set type
    string constant contractType = "$TYPE_STRING";
    
    address[] internal payToUsers;
    uint[] internal payToUsersAmount;

    constructor() public payable {
        require(msg.value >= serviceFee);
        //save created time
        createAt = now;
        //set wizard manager contract address
        //send data and fee to the manager contract
        WizardManager(managerAddress).createdNewContract.value(serviceFee)(contractType, rule);
    }

    function confirmContract() internal {
        //check that contract wasn't confirmed early
        require(contractConfirmationStatus == false);
        contractConfirmationStatus = true;
        ///pay money
        pay();
        //tell manager about contract confirmation
        WizardManager(managerAddress).contractConfirmed();
    }

    function pay() internal {
        //send ethers to all users from the list
        for (uint i = 0; i < payToUsers.length; i++) {
            payToUsers[i].transfer(payToUsersAmount[i]);
        }
    }
}