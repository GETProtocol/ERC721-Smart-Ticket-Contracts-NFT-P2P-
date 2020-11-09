pragma solidity ^0.6.0;

interface IERCMetaDataIssuersEvents is MetaDataIssuersEvents {
    // previously MetaDataTE

    function newTicketIssuer(address ticketIssuerAddress, string memory ticketIssuerName, string memory ticketIssuerUrl) external returns(bool success)
    function getTicketIssuer(address ticketIssuerAddress) external view  returns(address, string memory ticketIssuerName, string memory ticketIssuerUrl);
    function newEvent(address eventAddress, string memory eventName, string memory shopUrl, string memory coordinates, uint256 startingTime, address tickeerAddress) external returns(bool success);
    function getEventDataQuick(address eventAddress) external view returns(address, string memory eventName, address ticketIssuerAddress, string memory ticketIssuerName);
    function getEventDataAll(address eventAddress) external view returns(string memory eventName, string memory shopUrl, string memory locationCord, uint startTime, string memory ticketIssuerName, address, string memory ticketIssuerUrl);
    function isEvent(address eventAddress) external view returns(bool isIndeed);
    function getEventCount(address ticketIssuerAddress) external view returns(uint eventCount);
    function isTicketIssuer(address ticketIssuerAddress) external view returns returns(bool isIndeed);
    function getTicketIssuerCount() external view returns (uint ticketIssuerCount);
}