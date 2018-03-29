pragma solidity ^0.4.19;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./OnlyOwner.sol";

contract StandardToken is ERC20{
  using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    event Minted(address receiver, uint256 amount);
    
    

    

    function _transfer(address _from, address _to, uint256 _value) internal view returns (bool success){
      //prevent sending of tokens from genesis address or to self
      require(_from != address(0) && _from != _to);
      require(_to != address(0));
      //subtract tokens from the sender on transfer
      balances[_from] = balances[_from].safeSub(_value);
      //add tokens to the receiver on reception
      balances[_to] = balances[_to].safeAdd(_value);
      return true;
    }

  function transfer(address _to, uint256 _value) onlyPayloadSize(2*32) returns (bool success) 
  { 
    require(_value <= balances[msg.sender]);
      _transfer(msg.sender,_to,_value);
      Transfer(msg.sender, _to, _value);
      return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      uint256 _allowance = allowed[_from][msg.sender];
      //value must be less than allowed value
      require(_value <= _allowance);
      //balance of sender + token value transferred by sender must be greater than balance of sender
      require(balances[_to] + _value > balances[_to]);
      //call transfer function
      _transfer(_from,_to,_value);
      //subtract the amount allowed to the sender 
      allowed[_from][msg.sender] = _allowance.safeSub(_value);
      //trigger Transfer event
      Transfer(_from, _to, _value);
      return true;
    }

    function balanceOf(address _owner) public constant returns (uint balance) {
      return balances[_owner];
    }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].safeAdd(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.safeSub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  modifier onlyPayloadSize(uint size) {
    assert(msg.data.length == size + 4);
    _;
  } 

}

