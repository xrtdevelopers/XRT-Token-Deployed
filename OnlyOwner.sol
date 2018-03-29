pragma solidity ^0.4.19;

contract OnlyOwner {
  address public owner;
  /** 
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function OnlyOwner() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner. 
   */
  modifier isOwner {
    require(msg.sender == owner);
    _;
  }

}