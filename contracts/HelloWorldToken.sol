pragma solidity ^0.4.11;

import "./token/PausableToken.sol";
import "./lifecycle/Freezable.sol";


/**
 * @title HelloWorldToken
 * @dev HelloWorld Token contract
 */
contract HelloWorldToken is PausableToken, Freezable {

    /* Public variables of the token */
    string public name = "HelloWorldToken";
    string public symbol = "HLW";
    uint8 public decimals = 18; // Standard at 18
    uint256 public totalSupply = 1000000000; // Billions

    function HelloWorldToken() {
        balances[msg.sender] = totalSupply; // Give the owner all initial tokens
    }

    function transferFrom(address _from, address _to, uint256 _value) isNotFrozen returns (bool) {
        require(!isFrozen(_from));
        require(!isFrozen(_to));
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) isNotFrozen returns (bool) {
        require(!isFrozen(_to));
        return super.transfer(_to, _value);
    }
}