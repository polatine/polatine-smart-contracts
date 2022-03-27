//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Polatine is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => uint256) private _mintsLeft;
    mapping(address => string) private _artistName;
    mapping(address => uint256) private _deliverability;
    mapping(address => string) private _tokenUri;
    mapping(address => uint256) private _price;


    constructor() ERC721("Polatine", "PLT") {}

    function register(string memory name, uint256 mintsLeft, uint256 deliverability, string memory tokenURI, uint256 price) public {
        require(_artistName[_msgSender()] == "");
        _artistName[_msgSender()] = name;
        _mintsLeft[_msgSender()] = mintsLeft;
        _deliverability[_msgSender()] = deliverability;
        _tokenUri[_msgSender()] = tokenURI;
        _price[_msgSender()] = price;
    }

    function artistNameOf(address artistAddress) public view virtual returns (string memory) {
        return _artistName[artistAddress];
    }
    function mintsLeftOf(address artistAddress) public view virtual returns (uint256) {
        return _mintsLeft[artistAddress];
    }
    function deliverabilityOf(address artistAddress) public view virtual returns (uint256) {
        return _deliverability[artistAddress];
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function mintNFT(address artistAddress, uint256 mintsLeft)
        public
        returns (uint256)
    {
        require(_mintsLeft[_msgSender()]>0);
        _tokenIds.increment();
        
        uint256 newItemId = _tokenIds.current();
        _mint(_msgSender(), newItemId);
        _setTokenURI(newItemId, _tokenUri[_msgSender()]);
        _mintsLeft[_msgSender()] -= 1;

        return newItemId;
    }
}
