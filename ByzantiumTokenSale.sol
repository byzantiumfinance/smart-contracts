pragma solidity ^0.4.21;


interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract TokenSale {
    IERC20Token public tokenContract;
    uint256 public tokensPerWei;
    address owner;
    uint256 public tokensSold;

    event Sold(address buyer, uint256 amount);

    constructor(IERC20Token _tokenContract, uint256 _tokensPerWei) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokensPerWei = _tokensPerWei;
    }

    
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    function buyTokens(address beneficiary) public payable {
        uint256 weiAmount = msg.value;
        require(beneficiary != address(0), "beneficiary is the zero address");
        require(weiAmount != 0, "wei amount is 0");
        uint256 tokenAmount = safeMultiply(tokensPerWei,weiAmount);
        tokensSold += tokenAmount;
        require(tokenContract.balanceOf(address(this))>tokenAmount,"insufficient tokens available");
        tokenContract.transfer(beneficiary, tokenAmount);
        emit Sold(beneficiary, tokenAmount);
        _forwardFunds();
    }

    function _forwardFunds() internal {
        owner.transfer(msg.value);
    }


    function endSale() public {
        require(msg.sender == owner);
        require(tokenContract.transfer(owner, tokenContract.balanceOf(this)));
        msg.sender.transfer(address(this).balance);
    }

    //allows sending tokens directly to the contract
    function() public payable {
        buyTokens(msg.sender);
    }

}