pragma solidity ^0.4.23;

contract BasicContractInterface {
    //cance contract
    function cancel() public;
    //confirm contract
    function sendConfirmation() public;
    
    function getAdmins() public view returns(address[] memory);

    function getDecliners() public view returns(address[] memory);

    function getPaymentInfo() public view returns(address[] memory, uint[] memory);

}