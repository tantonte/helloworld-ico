pragma solidity ^0.4.11;

import './Ownable.sol';


contract WhiteList is Ownable {

    address[] whiteList;
    mapping(address => uint) whiteListIndex;
    event WhiteListAddress(address _addr, bool isWhiteListed);

    modifier onlyWhiteListed() {
        require(isWhiteListed(msg.sender));
        _;
    }

    function WhiteList() {
        whiteList.length = 2;
        whiteList[1] = msg.sender;
        whiteListIndex[msg.sender] = 1;
    }

    function addressAtIndex(uint index) external constant returns(address) {
        return address(whiteList[index + 1]);
    }

    function isWhiteListed(address _addr) constant returns(bool) {
        return whiteListIndex[_addr] > 0;
    }

    function addToWhiteList(address _addr) internal {
        require(!isWhiteListed(_addr)); // _addr must not already added to whitelist
        whiteListIndex[_addr] = whiteList.length;
        whiteList.length++;
        whiteList[whiteList.length - 1] = _addr;
        WhiteListAddress(_addr, true);
    }

    function removeFromWhiteList(address _addr) internal {
        uint index = whiteListIndex[_addr];
        whiteList[index] = address(0x0);
        whiteListIndex[_addr] = 0;
        WhiteListAddress(_addr, false);
    }

    function add(address[] _addrs) external onlyOwner {
        for (uint i = 0; i < _addrs.length; i++) {
            addToWhiteList(_addrs[i]);
        }
    }

    function remove(address[] _addrs) external onlyOwner {
        for (uint i = 0; i < _addrs.length; i++) {
            removeFromWhiteList(_addrs[i]);
        }
    }

}