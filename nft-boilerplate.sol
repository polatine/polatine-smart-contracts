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

    constructor() ERC721("Polatine", "PLT") {}

    function register(string memory name, uint256 mintsLeft, uint256 deliverability) public {
        _artistName[_msgSender()] = name;
        _mintsLeft[_msgSender()] = mintsLeft;
        _deliverability[_msgSender()] = deliverability;
    }

    function artistNameOf(address artistAddress) public view virtual returns (string memory) {
        return _artistName[artistAddress];
    }
    function mintrLeftOf(address artistAddress) public view virtual returns (uint256) {
        return _mintsLeft[artistAddress];
    }
    function deliverabilityOf(address artistAddress) public view virtual returns (uint256) {
        return _deliverability[artistAddress];
    }

    function mintNFT(address recipient, string memory tokenURI)
        public
        returns (uint256)
    {
        
        require(_mintsLeft[_msgSender()]>0);
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _mintsLeft[_msgSender()] -= 1;

        return newItemId;
    }
}