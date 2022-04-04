//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Polatine is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => uint256) private _mintsLeft; //How many mintings a subcollection has left
    mapping(address => string) private _subcollectionName; //Which subcollection a address represents
    mapping(address => uint256) private _deliverability; //Level of deliverability a subcollection has 
    mapping(address => string) private _tokenUri; //The Uri for a whole subcollection
    mapping(address => uint256) private _price; //The amount the artist gets as payment in WEI
    mapping(uint256 => address) private _tokenSubcollection; //Mapping from token to which subcollection it belongs to

    constructor() ERC721("Polatine", "PLT") {}

    function register(string calldata name, uint256 mintsLeft, uint256 deliverability, string calldata newTokenURI, uint256 price) public {
        require(keccak256(bytes(_subcollectionName[_msgSender()])) == keccak256(bytes("")), "Polatine: address already registered to a subcollection.");
        _subcollectionName[_msgSender()] = name;
        _mintsLeft[_msgSender()] = mintsLeft;
        _deliverability[_msgSender()] = deliverability;
        _tokenUri[_msgSender()] = newTokenURI;
        _price[_msgSender()] = price;
    }

    function subcollectionNameOf(address subcollectionAddress) public view virtual returns (string memory) {
        return _subcollectionName[subcollectionAddress];
    }
    function mintsLeftOf(address subcollectionAddress) public view virtual returns (uint256) {
        return _mintsLeft[subcollectionAddress];
    }
    function deliverabilityOf(address subcollectionAddress) public view virtual returns (uint256) {
        return _deliverability[subcollectionAddress];
    }
    function tokenSubcollection(uint256 tokenId) public view virtual returns (address) {
        return _tokenSubcollection[tokenId];
    }
    function priceOf(address subcollectionAddress) public view virtual returns (uint256) {
        return _price[subcollectionAddress];
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return _tokenUri[_tokenSubcollection[tokenId]];
    }

    function claimNFT(address subcollectionAddress)
        public payable
        returns (uint256)
    {
        require(keccak256(bytes(_subcollectionName[subcollectionAddress])) != keccak256(bytes("")), "Polatine: address does not represent a subcollection.");
        require(_mintsLeft[subcollectionAddress]>0, "Polatine: subcollection has no more mints left.");
        require(msg.value == _price[subcollectionAddress], "Polatine: deposit does not match subcollection price."); // msg.value is how much ether was sent
        
        payable(subcollectionAddress).transfer(msg.value);// send the ether to subcollection owner
        
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(_msgSender(), newItemId);

        _mintsLeft[subcollectionAddress] -= 1;
        _tokenSubcollection[newItemId] = subcollectionAddress;

        return newItemId;
    }
}
