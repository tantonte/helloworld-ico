pragma solidity ^0.4.11;

import "./math/SafeMath.sol";
import "./lifecycle/Destructible.sol";
import "./lifecycle/Pausable.sol";
import "./ownership/WhiteList.sol";
import "./HelloWorldToken.sol";


/**
 * @title TokenSeller
 * @dev The main token sale contract.
 * @dev During PreSale the owner will transfer an amount of Token equal to saleTarget this contract 
 */
contract TokenPreSeller is Pausable, Destructible {
    using SafeMath for uint;
    event TokenSold(address recipient, uint eth, uint tokens);
    event PreSaleClosed();

    HelloWorldToken public token; // address of Token contract
    WhiteList public whitelist; // Contract that contain list of eligible addresses
    address public wallet; // address of MultiSignatureWallet

    uint public saleTarget = 30000000; // 30000000 : target for presale is 300Millions
    uint public amountSold; // amount of tokens that is already sold to buyer

    uint public minToken = 1000; // Buyer must purchase Token MORE THAN this amount
    uint public maxToken = 10000000; // Buyer must purchase Token LESS THAN this amount

    uint public rate = 1000; // 1000 Tokens per 1 ETH
    uint public start = 1504112400; // timestamp of start date in seconds, from http://currentmillis.com/
    uint public duration = 31; // pre sale duration in days

 
    /* now (uint): alias of block.timestamp which is the current block timestamp as seconds since unix epoch */

    /**
    * @dev modifier to allow token creation only when the sale IS ON
    */
    modifier saleIsOn() {
        require(now > start && now < start.add(duration.mul(1 days))); // current time must passed the start date and not passed the last date
        _;
    }

    /**
    * @dev modifier to allow token sell only if saleTarget is not reach
    */
    modifier targetNotReached() {
        require(amountSold < saleTarget); // this contract still have token remain for sale
        _;
    }

    function TokenPreSeller(address _token, uint _whitelist) {
        token = HelloWorldToken(_token);
        whitelist = WhiteList(_whitelist);
        wallet = owner;
    }

    /**
    * @dev Allows only whitelisted address who transfer ETH
    * to contract account to receive Tokens. This method also transfer 
    * received ETH to the owner.
    * @param recipient the recipient to receive tokens. 
    */
    function sell(address recipient) targetNotReached saleIsOn whenNotPaused internal {
        require(whitelist.isWhiteListed(recipient));        // recipient must be in whitelist to be able to buy token
        uint etherPaid = msg.value;                         // amount received in wei: 1000000000000000000 wei = 1 ether
        uint tokens = etherPaid.mul(rate).div(1 ether);     // calculate amount of token recipient going to received from ETH paid amount
        require(isAmountValid(tokens));                     // check if amount of token can be transfer from this contract to recipient
        require(token.transfer(recipient, tokens));         // transfer tokens from this contract to recipient
        amountSold = amountSold.add(tokens);                // record amount sold
        wallet.transfer(etherPaid);                         // transfer ETH paid by recipient to multisignature wallet
        TokenSold(recipient, etherPaid, tokens);            // log event
    }

    /**
    * @dev Check if this contract still have enough token to sell.
    * @dev Determine if this amount of token is more than minimun amount
    * and less than maximun amount.
    * @param amount : amount of tokens that this contract is going to transfer to buyer
    */
    function isAmountValid(uint amount) internal returns (bool) {
        // the remaining token in this contract must be more than or equal to 'amount'
        // AND
        // 'amount' must be more than or equal to minimun buy amount and less than or equal to maximun buy amount
        return saleTarget.sub(amountSold) >= amount && (amount >= minToken && amount <= maxToken);
    }

    /**
    * @dev Allows the owner to finish the selling. This will transfer 
    * all remaining Tokens to this owner. Then the ownership of the   
    * token contract is also transfered to this owner.
    */
    function closeSale() external onlyOwner {
        token.transfer(wallet, token.balanceOf(this)); // transfer all remaining Tokens to owner
        PreSaleClosed();
    }

    /**
    * @dev Fallback function which receives ETH and created 
    * the appropriate number of tokens for the msg.sender.
    */
    function() external payable {
        sell(msg.sender);
    }

}
