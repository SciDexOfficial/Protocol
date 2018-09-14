pragma solidity ^0.4.23;


import "./BasicContractPrivate.sol";

contract BasicContract  is BasicContractPrivate {

    address[] private admins;
    address[] private decliners;

    mapping (uint => uint) private confirmationStatus;
    uint minimumConfirmationsCount = {{ minimum_confirmations_count }};

    uint confirmationsCount = 0;
    
    constructor() public payable {
        setPaymentInfo();
    }

    function setAdmins() private {
        {% for admin in admins_list %}
        admins.push({{ admin }});
        {% endfor %}
    }
    function setDecliners() private {
        {% for decliner in decliners_list %}
        decliners.push({{ decliner }});
        {% endfor %}
    }
    function getAdmins() public view returns(address[] memory) {
        return admins;
    }
    function getDecliners() public view returns(address[] memory) {
        return decliners;
    }

    function getContractRules() public view returns(string) {
        return rule;
    }

    function setPaymentInfo() internal {
        //set list of users who will get ethers
        //when contract will confirme
        {% for user in users_list %}
        payToUsers.push({{ user }});
        {% endfor %}
        {% for amount in amounts_list %}
        payToUsersAmount.push({{ amount }} ether);
        {% endfor %}
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