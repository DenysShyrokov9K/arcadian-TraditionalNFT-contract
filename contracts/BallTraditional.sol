// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./TokenMetaData.sol";

contract BallTraditional is ERC721URIStorage, Ownable {
    using Strings for uint256;
    uint256 public tokenId;
    string public imageBaseURI;
    string public currentUri;
    mapping(address => uint256[]) public userTokenIds;
    mapping(uint256 => uint256) public tokenIdType;

    struct Attribute {
        string mintType;
        uint256 category;
        uint256 currentPowerLvl;
        uint256 currentAccuracyLvl;
        uint256 currentSpinLvl;
        uint256 currentTimeLvl;
        uint256 maxPowerLvl;
        uint256 maxAccuracyLvl;
        uint256 maxSpinLvl;
        uint256 maxTimeLvl;
    }

    mapping(uint256 => uint256) public category;
    mapping(uint256 => uint256) public currentPowerLvl;
    mapping(uint256 => uint256) public currentAccuracyLvl;
    mapping(uint256 => uint256) public currentSpinLvl;
    mapping(uint256 => uint256) public currentTimeLvl;
    mapping(uint256 => uint256) public maxPowerLvl;
    mapping(uint256 => uint256) public maxAccuracyLvl;
    mapping(uint256 => uint256) public maxSpinLvl;
    mapping(uint256 => uint256) public maxTimeLvl;

    TokenMetadata.Attribute attribute;

    constructor() ERC721("BallTraditional", "BAT") {}

    function mint(uint256 typeId) external payable {
        require(msg.value >= 1 * 10**18);
        tokenId++;
        userTokenIds[msg.sender].push(tokenId);
        tokenIdType[tokenId] = typeId;
        _safeMint(msg.sender, tokenId);
        category[tokenId] = typeId;
        currentPowerLvl[tokenId] = 1;
        currentAccuracyLvl[tokenId] = 1;
        currentSpinLvl[tokenId] = 1;
        currentTimeLvl[tokenId] = 1;
        maxPowerLvl[tokenId] = 5;
        maxAccuracyLvl[tokenId] = 5;
        maxSpinLvl[tokenId] = 5;
        maxTimeLvl[tokenId] = 5;
        setTokenURI(tokenId);
    }

    function upgrade(
        uint256 _tokenId,
        uint256 _upgradePowerLvl,
        uint256 _upgradeAccuracyLvl,
        uint256 _upgradeSpinLvl,
        uint256 _upgradeTimeLvl
    ) external payable {
        require(msg.sender == ERC721.ownerOf(_tokenId));
        require(
            (_upgradePowerLvl >= 0 &&
                _upgradeAccuracyLvl >= 0 &&
                _upgradeSpinLvl >= 0 &&
                _upgradeTimeLvl >= 0 && 
                _upgradePowerLvl + currentPowerLvl[_tokenId] <= maxPowerLvl[_tokenId] && 
                _upgradeAccuracyLvl + currentAccuracyLvl[_tokenId] <= maxAccuracyLvl[_tokenId] && 
                _upgradeSpinLvl + currentSpinLvl[_tokenId] <= maxSpinLvl[_tokenId] && 
                _upgradeTimeLvl + currentTimeLvl[_tokenId] <= maxTimeLvl[_tokenId] 
                ),
            "Upgrade vale must be more than 0 and less than max value"
        );
        require(
            msg.value >=
                (_upgradePowerLvl +
                    _upgradeAccuracyLvl +
                    _upgradeSpinLvl +
                    _upgradeTimeLvl) *
                    5 *
                    10**17
        );
        currentPowerLvl[_tokenId] += _upgradePowerLvl;
        currentAccuracyLvl[_tokenId] += _upgradeAccuracyLvl;
        currentSpinLvl[_tokenId] += _upgradeSpinLvl;
        currentTimeLvl[_tokenId] += _upgradeTimeLvl;
        setTokenURI(_tokenId);
    }

    function setTokenURI(uint256 _tokenId) internal {
        attribute = TokenMetadata.Attribute(
            "BallTraditional",
            category[_tokenId],
            currentPowerLvl[_tokenId],
            currentAccuracyLvl[_tokenId],
            currentSpinLvl[_tokenId],
            currentTimeLvl[_tokenId],
            maxPowerLvl[_tokenId],
            maxAccuracyLvl[_tokenId],
            maxSpinLvl[_tokenId],
            maxTimeLvl[_tokenId]
        );
        string memory imageURI = string(
            abi.encodePacked(imageBaseURI, tokenIdType[_tokenId].toString())
        );
        string memory json = TokenMetadata.makeMetadataJSON(
            _tokenId,
            ERC721.ownerOf(_tokenId),
            "8Ball",
            imageURI,
            "8Ball is fantastic game",
            attribute
        );
        string memory _tokenURI = TokenMetadata.toBase64(json);
        currentUri = _tokenURI;
        _setTokenURI(_tokenId, _tokenURI);
    }

    function setImageBaseUri(string memory _imageBaseURI) external onlyOwner {
        imageBaseURI = _imageBaseURI;
    }

    function burn(uint256 _tokenId) external {
        require(
            msg.sender == ERC721.ownerOf(_tokenId),
            "Only the owner of NFT can transfer or bunt it"
        );
        for (
            uint256 i = 0;
            i < userTokenIds[ERC721.ownerOf(_tokenId)].length;
            i++
        ) {
            if (userTokenIds[ERC721.ownerOf(_tokenId)][i] == _tokenId) {
                userTokenIds[ERC721.ownerOf(_tokenId)][i] = userTokenIds[
                    ERC721.ownerOf(_tokenId)
                ][userTokenIds[ERC721.ownerOf(_tokenId)].length - 1];
                userTokenIds[ERC721.ownerOf(_tokenId)].pop();
            }
        }
        _burn(_tokenId);
    }

    function ownerWithdraw() external onlyOwner {
        address ownerAddress = msg.sender;
        (bool isSuccess, ) = ownerAddress.call{value: (address(this).balance)}(
            ""
        );
        require(isSuccess, "Withdraw fail");
    }
}
