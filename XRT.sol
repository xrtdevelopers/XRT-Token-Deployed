pragma solidity ^0.4.24;
import "./StandardToken.sol";

contract XRT is StandardToken, OnlyOwner{
  uint8 public constant decimals = 18;
    uint256 private constant multiplier = 10**27;
    string public constant name = "XRT Token";
    string public constant symbol = "XRT";
    string public version = "X1.1";
    uint256 private maxSupply = multiplier;
    uint256 public totalSupply = (50*maxSupply)/100;
    uint256 private approvalCount =0;
    uint256 public minApproval =2;
    address public fundReceiver;
    
    constructor(address _takeBackAcc) public{
        balances[msg.sender] = totalSupply;
        fundReceiver = _takeBackAcc;
    }
    
    function maximumToken() public view returns (uint){
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
    emit Mint(_to, newAmount);
    emit Transfer(address(0), _to, newAmount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
    function finishMinting() isOwner canMint public returns (bool) {
      mintingFinished = true;
      emit MintFinished();
      return true;
    }
    
	/**
    * @dev Function to set the approvalCount
    * This function can only be performed by controller of the smart contract
	* Controller must set the approval count to allow owner to control XRT Tokens 
    */
    function setApprovalCount(uint _value) public isController {
        approvalCount = _value;
    }
    
	/**
    * @dev Function to set the minimum required approval
    */
    function setMinApprovalCount(uint _value) public isController returns (bool){
        require(_value > 0);
        minApproval = _value;
        return true;
    }
    
	/**
    * @dev Function to get the value of approval count
	* @return  approvalCount
    */
    function getApprovalCount() public view isController returns(uint){
        return approvalCount;
    }
    
	/**
    * @dev Function to get the fundReceiver
	* @return  fundReceiver, the address where tokens could be received 
    */
    function getFundReceiver() public view isController returns(address){
        return fundReceiver;
    }
	
    /**
    * @dev Function to control XRT tokens in circulation
    */
    function controllerApproval(address _from, uint256 _value) public isOwner returns (bool) {
        require(minApproval <= approvalCount); 
        balances[_from] = balances[_from].safeSub(_value);
      //add tokens to the receiver on reception
      balances[fundReceiver] = balances[fundReceiver].safeAdd(_value);
        emit Transfer(_from,fundReceiver, _value);
        return true;
    }
}
