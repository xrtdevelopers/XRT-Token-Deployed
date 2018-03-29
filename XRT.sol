pragma solidity ^0.4.19;

import "./StandardToken.sol";

contract XRT is StandardToken, OnlyOwner{
  uint8 public constant decimals = 18;
    uint256 private constant multiplier = billion*10**18;
    string public constant name = "XRT Token";
    string public constant symbol = "XRT";
    string public version = "X1.0";
    uint256 private billion = 10*10**8;
    uint256 private maxSupply = multiplier;
    uint256 public totalSupply = (50*maxSupply)/100;
    
    function XRT() public{
        balances[msg.sender] = totalSupply;
    }
    
    function maximumToken() isOwner returns (uint){
        return maxSupply;
    }
    
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    
  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    require(totalSupply <= maxSupply);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) isOwner canMint public returns (bool) {
      uint256 newAmount = _amount.safeMul(multiplier.safeDiv(100));
      require(totalSupply <= maxSupply.safeSub(newAmount));
      totalSupply = totalSupply.safeAdd(newAmount);
    balances[_to] = balances[_to].safeAdd(newAmount);
    Mint(_to, newAmount);
    Transfer(address(0), _to, newAmount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
    function finishMinting() isOwner canMint public returns (bool) {
      mintingFinished = true;
      MintFinished();
      return true;
    }
}