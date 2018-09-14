pragma solidity ^0.4.23;

import "./WizardManager.sol";
import "./BasicContractInterface.sol";
import "./Ownable.sol";
import "./WizardManager.sol";

contract BasicContractPrivate is Ownable, BasicContractInterface {
    
    address internal managerAddress = {{ manager_address }};

    uint createAt;
    //by default it's 0.01
    uint constant serviceFee = {{ service_fee }} ether;

    bool contractConfirmationStatus = false;
    //set rule
    string constant rule = "{{ rule }}}";
    //set type
    string constant contractType = "{{ type }}";
    
    address[] internal payToUsers;
    uint[] internal payToUsersAmount;

    constructor() public payable {
        require(msg.value >= {{ minimum_price }});
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