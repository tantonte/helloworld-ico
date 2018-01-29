pragma solidity ^0.4.11;

import "./math/SafeMath.sol";
import "./lifecycle/Destructible.sol";
import "./lifecycle/Pausable.sol";
import "./ownership/WhiteList.sol";
import "./HelloWorldToken.sol";


/**
 * @title TokenSeller
 * @dev The main token sale contract.
 * @dev During ICO the owner will transfer an amount of Token equal to saleTarget this contract 
 */
contract TokenSeller is Pausable, Destructible {
    using SafeMath for uint;
    event TokenSold(address recipient, uint eth, uint tokens);
    event SaleClosed();

    HelloWorldToken public token; // Token contract
    WhiteList public whitelist; // Contract that contain list of eligible addresses
    address public wallet;

    uint public saleTarget = 400000000; // target for public ICO is 400 Millions
    uint public amountSold; // Amount of tokens sold to buyer

    uint public minToken = 1000; // Buyer must purchase Token MORE THAN OR EQUAL this amount
    uint public maxToken = 10000000; // Buyer must purchase Token LESS THAN OR EQUAL this amount

    uint public rate = 1000; // 1000 Tokens per 1 ETH
    uint public start = 1504112400; // Timestamp of start date in seconds, from http://currentmillis.com/
    uint public duration = 31; // Duration of sale in days
 
    /* now (uint): alias of block.timestamp which is the current block timestamp as seconds since unix epoch */

    /**
    * @dev modifier to allow token creation only when the sale IS ON
    */
    modifier saleIsOn() {
        require(now > start && now < start.add(duration.mul(1 days)));  // Current time is still in sale duration
        _;
    }

    /**
    * @dev modifier to allow token sell only if saleTarget is not reach
    */
    modifier targetNotReached() {
        require(amountSold < saleTarget); // Amount of token sold must be less than targetted amount
        _;
    }

    /**
    * Constructor that identify token contract and 
    * assign whitelist for this contract to look into
    * and wallet address to transfer received ETH to.
    */
    function TokenSeller(address _token, address _whitelist) {
        token = HelloWorldToken(_token);
        whitelist = WhiteList(_whitelist);
        wallet = owner;
    }

    /**
    * @dev Allows only whitelisted address who transfer ETH
    * to contract account to receive Tokens. This method also transfer 
    * received ETH to the owner.
    * @param recipient the recipient to receive tokens. 
    * @param etherPaid amount received in wei: 1000000000000000000 wei = 1 ether 
    */
    function sell(address recipient, uint etherPaid) targetNotReached saleIsOn whenNotPaused internal {
        require(whitelist.isWhiteListed(recipient));    // recipient must be in whitelist
        uint tokens = exchange(etherPaid);              // convert received ETH to Tokens
        require(isAmountValid(tokens));                 // validate amount
        require(token.transfer(recipient, tokens));     // transfer Token from this contract to recipient
        amountSold = amountSold.add(tokens);            // record amount sold
        wallet.transfer(etherPaid);                     // transfer received ETH to MultiSignatureWallet
        TokenSold(recipient, etherPaid, tokens);        // log event
    }

    /**
    * @dev Check if this contract still have enough token to sell.
    * @dev Determine if this amount of token is more than minimun amount
    * and less than maximun amount.
    * @param amount amount of token to be transferred to buyer
    */
    function isAmountValid(uint amount) internal returns (bool) {
        bool isEnoungh = saleTarget.sub(amountSold) >= amount;          // this contract still have enough tokens left to sell
        bool isInRange = (amount >= minToken && amount <= maxToken);    // amount is higher than minimun and lower than maximun
        return isEnoungh && isInRange;                                  // both condition must be true
    }

    /**
    * @dev Get number of tokens corresponding to ETH received
    * @param value an ETH amount in wei, 1000000000000000000 wei = 1 ether
    */
    function exchange(uint value) internal returns (uint) {
        uint base = rate;                                                  // base price (1000 tokens / 1 ether)
        uint bonus = 0;
        if (now > start && now < start.add(1 days)) {                      // during first date
            bonus = 20;                                                    // bonus 20%
        } else if (now > start.add(1 days) && now < start.add(2 days)) {   // during second date
            bonus = 15;                                                    // bonus 15%
        } else if (now > start.add(2 days) && now < start.add(3 days)) {   // during third date
            bonus = 10;                                                    // bonus 10%
        } else if (now > start.add(3 days) && now < start.add(4 days)) {   // during forth date
            bonus = 5;                                                     // bonus 5%
        }
        uint actualRate = base.add(base.mul(bonus).div(100));              // amount of tokens(plus bonus) per 1 ether
        uint amount = actualRate.mul(value).div(1 ether);                  // rate multiplied by value(in wei) and divided by 1 ether
        return amount;                                            
    }
  
    /**
    * @dev Allows the owner to finish the selling. This will transfer 
    * all remaining Tokens to this owner. Then the ownership of the   
    * token contract is also transfered to this owner.
    */
    function closeSale() external onlyOwner {
        token.transfer(owner, token.balanceOf(this)); // transfer all remaining Tokens to owner
        SaleClosed();
    }

    /**
    * @dev Fallback function which receives ETH and created 
    * the appropriate number of tokens for the msg.sender.
    */
    function() external payable {
        sell(msg.sender, msg.value); // give tokens to msg.sender
    }

}
