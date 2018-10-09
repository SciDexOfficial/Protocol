pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "./WizardManager.sol";
import "./BasicContractInterface.sol";
import "./Ownable.sol";

contract BasicContractPrivate is Ownable, BasicContractInterface {
    
    enum ContractStatusEnum {created, completed, canceled, cancelingByProvider, cancelingByClient}
    enum ContractRuleStatusEnum {inProgress, completed, payed}
    using SafeMath for uint;

    address internal managerAddress = 0x9f0ff1Ab4ee32D0CeD7109729dD466A223dbA2Db;
    address internal oraclAddress = 0x9f0ff1Ab4ee32D0CeD7109729dD466A223dbA2Db;


    uint createAt;
    uint constant serviceFee = 0.01 ether;
    
    uint internal completionRate = 10000;
    
    ContractStatusEnum internal contractStatus = ContractStatusEnum.created;
    //set rule
    string constant rules = "$RULE_STRING";
    
    address constant payToUser = 0x9f0ff1Ab4ee32D0CeD7109729dD466A223dbA2Db;
    uint[] internal payToUsersAmount;
    mapping(uint => ContractRuleStatusEnum) rulesStatuses;
    mapping(uint => string) rulesParams;

    constructor() public payable {
        require(msg.value >= serviceFee);
        //save created time
        createAt = now;
        setPaymentInfo();
        //set wizard manager contract address
        //send data and fee to the manager contract
        WizardManager(managerAddress).createdNewContract.value(serviceFee)(msg.sender, payToUser, payToUsersAmount, rules);
    }

    function setPaymentInfo() private {
        //set list of users who will get ethers
        //when contract will confirm
        
        payToUsersAmount.push(0.1 ether);
    }

    function sendRuleConfirmation(uint ruleIndex) public {
        require(contractStatus != ContractStatusEnum.completed && contractStatus != ContractStatusEnum.canceled);
        require(rulesStatuses[ruleIndex] == ContractRuleStatusEnum.inProgress);
        require(msg.sender == oraclAddress || msg.sender == owner);
        
        rulesStatuses[ruleIndex] = ContractRuleStatusEnum.completed;
        WizardManager(managerAddress).contractRuleConfirmed(ruleIndex, "");

        pay(ruleIndex);
    }

    function sendRuleConfirmationWithParams(uint ruleIndex, string params) public {
        require(contractStatus != ContractStatusEnum.completed && contractStatus != ContractStatusEnum.canceled);
        require(rulesStatuses[ruleIndex] == ContractRuleStatusEnum.inProgress);
        require(msg.sender == owner);
        
        rulesStatuses[ruleIndex] = ContractRuleStatusEnum.completed;
        rulesParams[ruleIndex] = params;

        WizardManager(managerAddress).contractRuleConfirmed(ruleIndex, params);

        pay(ruleIndex);
    }

    function sendCanceling() public {
        require(contractStatus != ContractStatusEnum.completed && contractStatus != ContractStatusEnum.canceled);
        if (msg.sender == oraclAddress) {
            contractStatus = ContractStatusEnum.canceled;
            cancel();
        } else if (msg.sender == owner) {
            if (contractStatus == ContractStatusEnum.created) {
                contractStatus = ContractStatusEnum.cancelingByClient;
                WizardManager(managerAddress).contractCanceling(msg.sender);
            } else if (contractStatus == ContractStatusEnum.cancelingByProvider) {
                contractStatus = ContractStatusEnum.canceled;
                cancel();
            }
        } else if (msg.sender == payToUser) {
            if (contractStatus == ContractStatusEnum.created) {
                contractStatus = ContractStatusEnum.cancelingByProvider;
                WizardManager(managerAddress).contractCanceling(msg.sender);
            } else if (contractStatus == ContractStatusEnum.cancelingByClient) {
                contractStatus = ContractStatusEnum.canceled;
                cancel();
            }
        }
    }

    function cancel() private {
        WizardManager(managerAddress).contractCanceled();
        selfdestruct(owner);
    }

    function pay(uint ruleIndex) private {
        //send ethers to all users from the list
        require(rulesStatuses[ruleIndex] == ContractRuleStatusEnum.completed);
        rulesStatuses[ruleIndex] = ContractRuleStatusEnum.payed;
        
        payToUser.transfer(payToUsersAmount[ruleIndex]);
        WizardManager(managerAddress).sentPaymentToUser(payToUsersAmount[ruleIndex], payToUser);
    }

}