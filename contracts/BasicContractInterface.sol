pragma solidity ^0.4.23;

contract BasicContractInterface {

    function getPaymentInfo() public view returns(address, uint[] memory);

    function getRules() public view returns(string memory);

    function setCompletionRate(uint rate) public;
}