pragma solidity ^0.4.23;


import "./BasicContractPrivate.sol";

contract BasicContract  is BasicContractPrivate {
    
    function getPaymentInfo() public view returns(address, uint[] memory) {
        return (payToUser, payToUsersAmount);
    }
    
    function getRules() public view returns(string memory) {
        return rules;
    }
}