//SPDX-License-Identifier:MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract Nfti is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;
    address contractAddress;

    constructor(address MarketplaceAdd) ERC721("Daporisho", "DPH") {
        contractAddress = MarketplaceAdd;
    }

    function createToken(string memory tokenURI) public returns (uint256) {
        tokenIds.increment();
        uint256 newId = tokenIds.current();
        _mint(msg.sender, newId);
        _setTokenURI(newId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newId;
    }
}

contract NftMarket is ReentrancyGuard {
    address private owner;
    uint256 listingPrice = 10 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    using Counters for Counters.Counter;
    Counters.Counter private _itemId;
    Counters.Counter private _itemSold;
    event NftCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price
    );
    struct NftItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
    }
    mapping(uint256 => NftItem) public idToNft;

    function createItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "So di nkan gidi");
        require(msg.value == listingPrice, "Not listing price");

        _itemId.increment();
        uint256 itemId = _itemId.current();
        idToNft[itemId] = NftItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price
        );
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        emit NftCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price
        );
    }

    function CreateSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToNft[itemId].price;
        uint256 tokenId = idToNft[itemId].tokenId;
        require(msg.value == price, "not enough");
        _itemSold.increment();
        idToNft[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToNft[itemId].owner = payable(msg.sender);
        payable(owner).transfer(listingPrice);
    }

    function Fethnumofsold() public view returns (NftItem[] memory) {
        uint256 itemAv = _itemId.current();
        uint256 itemSo = _itemSold.current();
        uint256 unsold = itemAv - itemSo;
        uint256 currentIndex = 0;
        NftItem[] memory item = new NftItem[](unsold);
        for (uint256 i = 0; i < itemAv; i++) {
            if (idToNft[i + 1].owner == msg.sender) {
                uint256 currentId = idToNft[i + 1].itemId;
                NftItem storage currentIt = idToNft[currentId];
                item[currentIndex] = currentIt;
                currentIndex += 1;
            }
        }
        return item;
    }

    function fetchitemsleft() public view returns (NftItem[] memory) {
        uint256 itemAv = _itemId.current();
        uint256 remItem = 0;
        uint256 Index = 0;
        NftItem[] memory Items = new NftItem[](remItem);
        for (uint256 i = 0; i < itemAv; i++) {
            if (idToNft[i + 1].owner == msg.sender) {
                remItem += 1;
                uint256 newId = idToNft[i + 1].itemId;
                NftItem storage currIt = idToNft[newId];
                Items[Index] = currIt;
                Index += 1;
            }
        }
        return Items;
    }
}
