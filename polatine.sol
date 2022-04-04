//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Polatine is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => uint256) private _mintsLeft; //How many mintings a subcollection has left
    mapping(address => string) private _tokenUri; //The Uri for a whole subcollection
    mapping(address => uint256) private _price; //The amount the artist gets as payment in WEI
    mapping(uint256 => address) private _tokenSubcollection; //Mapping from token to which subcollection it belongs to

    constructor() ERC721("Polatine", "PLT") {}

    function register(uint256 mintsLeft, string calldata newTokenURI, uint256 price) public {
        require(_price[_msgSender()] == 0, "Polatine: address already registered to a subcollection.");
        require(price > 0, "Polatine: price must be non-zero positive number.");
        _mintsLeft[_msgSender()] = mintsLeft;
        _tokenUri[_msgSender()] = newTokenURI;
        _price[_msgSender()] = price;
    }

    function mintsLeftOf(address subcollectionAddress) public view virtual returns (uint256) {
        return _mintsLeft[subcollectionAddress];
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
        require(_price[subcollectionAddress] > 0, "Polatine: address does not represent a subcollection.");
        require(_mintsLeft[subcollectionAddress] > 0, "Polatine: subcollection has no more mints left.");
        require(msg.value == _price[subcollectionAddress], "Polatine: deposit does not match subcollection price."); // msg.value is how much ether was sent
        
        payable(subcollectionAddress).transfer(msg.value);// send the ether to subcollection owner
        
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(_msgSender(), newItemId);

        _mintsLeft[subcollectionAddress] -= 1;
        _tokenSubcollection[newItemId] = subcollectionAddress;

        return newItemId;
    }
    
    function claimNFT(address subcollectionAddress, uint count)
        public payable
        returns (uint256)
    {
        require(_price[subcollectionAddress] > 0, "Polatine: address does not represent a subcollection.");
        require(_mintsLeft[subcollectionAddress] >0, "Polatine: subcollection has no more mints left.");
        require(_mintsLeft[subcollectionAddress] >= count, "Polatine: claim higher than mints left.");
        require(msg.value == _price[subcollectionAddress]*count, "Polatine: deposit does not match subcollection price."); // msg.value is how much ether was sent

        payable(subcollectionAddress).transfer(msg.value);// send the ether to subcollection owner
        uint256 newItemId;
        for (uint i = 0; i < count; i++) {
            _tokenIds.increment();
            newItemId = _tokenIds.current();
            _mint(_msgSender(), newItemId);
            _tokenSubcollection[newItemId] = subcollectionAddress;
        }
        _mintsLeft[subcollectionAddress] -= count;

        return newItemId;
    }
}
