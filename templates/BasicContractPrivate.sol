pragma solidity ^0.4.23;

import "./WizardManager.sol";
import "./BasicContractInterface.sol";
import "./Ownable.sol";
import "./WizardManager.sol";


pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "./WizardManager.sol";
import "./BasicContractInterface.sol";
import "./Ownable.sol";

contract BasicContractPrivate is Ownable, BasicContractInterface {
    
    enum ContractStatusEnum {created, completed, canceled, cancelingByProvider, cancelingByClient}
    enum ContractRuleStatusEnum {inProgress, completed, payed}
    using SafeMath for uint;

    address internal managerAddress = {{ manager_address }};
    address internal oraclAddress = {{ oracl_address }};


    uint createAt;
    uint constant serviceFee = {{ service_fee }} ether;
    
    uint internal completionRate = 10000;
    
    ContractStatusEnum internal contractStatus = ContractStatusEnum.created;
    //set rule
    string constant rules = "{{ rule }}}";
    
    address constant payToUser = {{ pay_to_user_address }};
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
        {% for payment in payments_list %}
        payToUsersAmount.push({{ payment }} ether);
        {% endfor %}
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
