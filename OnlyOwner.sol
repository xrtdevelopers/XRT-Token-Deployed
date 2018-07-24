pragma solidity ^0.4.24;
/**
* @dev Added controller modifier to add the functionality similar as multisig wallet
*
* Controller have limited field of work. Controller can allow the Owner of the smart contract to burn  user's tokens
* The burned tokens will be sent to genesis block. So even the owner or anyone else couldn't use the burned tokens
* The controller option is added to prevent scam activities. This will provide the benefit to authentic users.
* Controller option is reserved for rare and unexpected situations.
*/
contract OnlyOwner {
  address public owner;
  address private controller;
  event Controller(address _user);
  /** 
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
    controller = owner;
  }


  /**
   * @dev Throws if called by any account other than the owner. 
   */
  modifier isOwner {
    require(msg.sender == owner);
    _;
  }
  
  /**
   * @dev Throws if called by any account other than the controller. 
   */
  modifier isController {
    require(msg.sender == controller);
    _;
  }
  
  function replaceController(address _user) isController public returns(bool){
    require(_user != address(0x0));
    controller = _user;
    emit Controller(controller);
    return true;   
  }

}
