// SPDX-License-Identifier: Unlicenced
pragma solidity 0.8.18;
contract TokenContract {

    address public owner;

    struct Receivers {
        string name;
        uint256 tokens;
    }

    mapping(address => Receivers) public users;

    // Event to log token transfers
    event TokensSent(address from, address receiver, uint256 amount);

    // Event for token purchase
    event TokenPurchased(address purchaser, uint256 amountOfETH, uint256 amountOfTokens);

    // Token price in wei with 1 ETH = 10^18 wei, so 5 ETH is 5 * 10^18 wei
    uint256 public constant TOKEN_PRICE = 5e18;
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    function double(uint _value) public pure returns (uint){
        return _value*2;
    }

    function register(string memory _name) public{
        users[msg.sender].name = _name;
        // Optionally set initial tokens for a new user to 0
        users[msg.sender].tokens = 0;
    }

    function giveToken(address _receiver, uint256 _amount) onlyOwner public{
        require(users[owner].tokens >= _amount, "Not enough tokens");
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;

        // Emit an event when tokens are sent
        emit TokensSent(owner, _receiver, _amount);
    }

    // Function to buy tokens with Ether
    function buyTokens() public payable {
        uint256 tokensToBuy = msg.value / TOKEN_PRICE; // Calculate the number of tokens to buy
        uint256 cost = tokensToBuy * TOKEN_PRICE; // Calculate the cost of the tokens

        // Ensure the buyer sends enough Ether to buy at least one token
        require(msg.value >= TOKEN_PRICE, "Not enough ETH sent; 1 token costs 5 ETH");

        // Check if the owner has enough tokens to sell
        require(users[owner].tokens >= tokensToBuy, "Not enough tokens available for purchase");

        // Refund any excess ETH sent by the buyer
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }

        // Transfer the tokens to the buyer
        users[owner].tokens -= tokensToBuy;
        users[msg.sender].tokens += tokensToBuy;

        // Emit the purchase event
        emit TokenPurchased(msg.sender, cost, tokensToBuy);
    }

    // Function to check the token balance of a user
    function balanceOf(address _user) public view returns (uint256) {
        return users[_user].tokens;
    }
}