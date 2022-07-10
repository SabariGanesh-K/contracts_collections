// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract DAOIdCard is ERC721URIStorage {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address owner;
  constructor() ERC721("DAOIdCard","Mem"){
        owner = msg.sender;

  }
  mapping (address=>bool) public providedId;

modifier onlyAdmin() {
    require(msg.sender==owner);
    _;
}
  function provideId(address to)  onlyAdmin external {
        providedId[to] = true;

  }
  mapping (address=>string)  public showId;

  function claimId(string memory tokenURI) public returns(uint256) {
      require(providedId[msg.sender],"ID not provided.Contact the admin.");
    
      _tokenIds.increment();
      uint256 newItemId = _tokenIds.current();
      _mint(msg.sender,newItemId);
    
    _setTokenURI(newItemId,tokenURI);
    showId[msg.sender] = tokenURI;
    providedId[msg.sender] = false;

    return newItemId;
  }


}