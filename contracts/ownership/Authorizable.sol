pragma solidity ^0.4.11;

contract Authorizable {

  address[] authorizers;
  mapping(address => uint) authorizerIndex;

  modifier onlyAuthorized() {
    require(isAuthorized(msg.sender));
    _;
  }

  function Authorizable() {
    authorizers.length = 2;
    authorizers[1] = msg.sender;
    authorizerIndex[msg.sender] = 1;
  }

  function authorizerAtIndex(uint index) external constant returns(address) {
    return address(authorizers[index + 1]);
  }

  function isAuthorized(address _addr) constant returns(bool) {
    return authorizerIndex[_addr] > 0;
  }

  function authorize(address _addr) external onlyAuthorized {
    authorizerIndex[_addr] = authorizers.length;
    authorizers.length++;
    authorizers[authorizers.length - 1] = _addr;
  }

}