//SPDX-License-Identifier: MIT;
pragma solidty ^0.8.9;

import "erc721a/contracts/ERC721A.sol";
import "./Ownable.sol";

contract WomenWorld is ERC721A, Ownable{

    struct CustomMetadata {
        string URI;
        bool status;
    }

    struct UpdateMetadata {
        uint256 tokenId;
        string uri;
    }

    uint256 public maxSupply = 2222;
    bool public revealed;
    string private defaultURI;
    string private BaseURI;

    mapping(uint256 => CustomMetadata) private customizedMetadata;

    event Revealed(uint256 revealedTimestamp);
    constructor(string memory _BaseURI, string memory _defaultURI) ERC721A("Women's world", "WW") {
        BaseURI = _BaseURI;
        defaultURI = _defaultURI;
    }

    function mint(uint256 quality) public {
        require(quality + totalSupply() <= maxSupply, "NFT supply is full");
        _mint(msg.sender, quality);
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        if (!revealed) return defaultURI;
        if (customizedMetadata[tokenId].status) return customizedMetadata[tokenId].URI;

        string memory baseURI = _baseURI();
        
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId), ".json")) : defaultURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return BaseURI;
    }

    function reveal() external onlyOwner {
        revealed = true;
        emit Revealed(block.timestamp);
    }

    function updateMetadata(UpdateMetadata[] memory _URIs) external onlyOwner {
        require(_URIs.length > 0, "WW: empty uris");
        for (uint256 i; i < _URIs.length; i ++) {
            customizedMetadata[_URIs[i].tokenId] = CustomMetadata(_URIs[i].uri, true)
        }
    }
}