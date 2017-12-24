pragma solidity ^0.4.11;

import '../ownership/Ownable.sol';


contract Freezable is Ownable {

    mapping (address => bool) public frozenAccounts;
    event Frozen(address indexed account, bool isFrozen);

    modifier isNotFrozen () {
        require(!frozenAccounts[msg.sender]);
        _;
    }

    function freezeAccount (address _addr, bool freeze) onlyOwner {
        require(freeze != isFrozen(_addr)); // don't freeze a frozen account
        frozenAccounts[_addr] = freeze;
        Frozen(_addr, freeze);
    }

    function freezeAccounts (address[] _addrs, bool freeze) onlyOwner {
        for (uint i = 0; i < _addrs.length; i++) {
            address _addr = _addrs[i];
            require(freeze != isFrozen(_addr)); // don't freeze a frozen account
            frozenAccounts[_addr] = freeze;
            Frozen(_addr, freeze);
        }
    }

    function isFrozen (address _addr) returns (bool) {
        return frozenAccounts[_addr];
    }

}