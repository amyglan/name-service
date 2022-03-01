//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { StringUtils } from "./libraries/StringUtils.sol";
import { Base64 } from "./libraries/Base64.sol";
import "hardhat/console.sol";

contract Domains is ERC721URIStorage, Ownable{

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    string public tld;

    mapping(uint => string) domainNames;

    mapping(string => address) domainMap;

    mapping(string => string) records;

    error Unauthorized();
    error AlreadyRegistered();
    error Unregistered(string name);
    error InvalidName(string name);

    string svg_one = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400" xml:space="preserve" width="400" height="400"><path d="M200 76.296c-29.68 0-53.74 43.404-53.74 77.888 0 16.764 5.72 31.952 14.976 43.168 11.1 7.4 24.424 11.728 38.764 11.728s27.664-4.328 38.764-11.728c9.256-11.216 14.976-26.404 14.976-43.168 0-34.48-24.06-77.888-53.74-77.888z" fill="#00000"/><path d="M236.14 184.468c-9.92 7.912-22.468 12.668-36.14 12.668s-26.22-4.756-36.14-12.668a91.942 91.942 0 0 0-4.94 2.256c-.776.384-1.528.812-2.288 1.224 1.584 2.64 3.304 5.164 5.216 7.484 10.924 7.284 24.036 11.544 38.148 11.544s27.224-4.26 38.148-11.544c1.912-2.316 3.632-4.844 5.216-7.484-.76-.412-1.508-.84-2.288-1.224a88.92 88.92 0 0 0-4.932-2.256z" fill="#00000"/><path d="M206.884 101.472c-2.252-.532-4.548-.836-6.884-.836s-4.632.304-6.884.836c-25.36 5.964-44.932 23.728-44.932 54.26 0 3.884.352 7.664.96 11.34a58.312 58.312 0 0 0 14.712 17.396c9.92 7.912 22.468 12.668 36.14 12.668s26.22-4.756 36.14-12.668a58.2 58.2 0 0 0 14.712-17.396c.608-3.676.96-7.456.96-11.34.008-30.532-19.564-48.296-44.924-54.26z" fill="#00000"/><path fill="#f1f5db" d="M244 141.532a44 61.388 0 0 1-44 61.388 44 61.388 0 0 1-44-61.388 44 61.388 0 0 1 88 0z"/><path d="M206.884 101.472c-2.252-.532-4.548-.836-6.884-.836s-4.632.304-6.884.836c2.26-.268 4.552-.444 6.884-.444s4.624.176 6.884.444zm-50.52 86.62.268-.144a63.892 63.892 0 0 1-3.08-5.736c.856 2.02 1.772 3.996 2.812 5.88zm87.272 0c1.04-1.884 1.96-3.86 2.816-5.88a63.349 63.349 0 0 1-3.08 5.736l.264.144z" fill="none"/><path d="M264.436 203.312c-8.156-8.02-10.316-20.248-4.908-30.332a67.12 67.12 0 0 0 7.964-31.812c0-37.276-30.216-84.196-67.492-84.196s-67.492 46.924-67.492 84.196c0 11.508 2.884 22.336 7.964 31.812 5.408 10.08 3.248 22.308-4.908 30.332C119.752 218.86 110 240.092 110 263.548v57.868c0 11.936 10.08 21.612 22.512 21.612h134.98c12.432 0 22.512-9.676 22.512-21.612v-57.868c-.004-23.456-9.76-44.688-25.568-60.236zm-13.58-36.24a66.892 66.892 0 0 1-4.404 15.14c-.856 2.02-1.772 3.996-2.816 5.88l-.268-.144a61.44 61.44 0 0 1-5.216 7.484c-10.924 7.284-24.036 11.544-38.148 11.544s-27.224-4.26-38.148-11.544a61.136 61.136 0 0 1-5.216-7.484l-.268.144c-1.04-1.884-1.96-3.86-2.812-5.88a66.66 66.66 0 0 1-4.404-15.144 69.364 69.364 0 0 1-.96-11.34c0-30.532 19.572-48.292 44.932-54.26 2.252-.532 4.548-.836 6.884-.836s4.632.304 6.884.836c25.36 5.964 44.932 23.728 44.932 54.26a70.72 70.72 0 0 1-.972 11.344z" fill="#00000"/><path fill="none" stroke="red" stroke-width="8" stroke-linecap="round" stroke-miterlimit="10" d="M186.828 224.972v41.5"/><path fill="red" d="M194.828 266.472a8 8 0 0 1-8 8 8 8 0 0 1-8-8 8 8 0 0 1 16 0z"/><path fill="none" stroke="red" stroke-width="8" stroke-linecap="round" stroke-miterlimit="10" d="M210.828 224.972v73.5"/><path fill="red" d="M218.828 298.472a8 8 0 0 1-8 8 8 8 0 0 1-8-8 8 8 0 0 1 16 0z"/><path d="M165.288 143.2c2.452-1.852 4.904-2.82 7.356-3.472 2.452-.708 4.904-.896 7.356-.976 2.452.088 4.904.28 7.356.988 2.452.656 4.904 1.616 7.356 3.46v1.6L180 144.584l-14.712.216v-1.6zm40 0c2.452-1.748 4.904-2.664 7.356-3.276 2.452-.668 4.904-.848 7.356-.92 2.452.084 4.904.264 7.356.932 2.452.616 4.904 1.528 7.356 3.264v1.6L220 144.556l-14.712.244v-1.6zm-39.5-19.008 28.424 7.616m-28.216-8.388c5.368-1.088 10.252-.356 15.012.828 4.712 1.364 9.304 3.172 13.412 6.788l-.416 1.544c-4.656-1.576-9.412-2.768-14.116-4.164-4.772-1.144-9.488-2.492-14.308-3.452l.416-1.544zm39.792 8.388 28.424-7.616m-28.632 6.844c4.104-3.628 8.7-5.432 13.412-6.788 4.764-1.172 9.644-1.904 15.012-.828l.416 1.544c-4.82.964-9.536 2.312-14.308 3.452-4.704 1.396-9.46 2.588-14.116 4.164l-.416-1.544zM205.124 177 200 195.72 194.876 177zm-11.5-8h-19.748l-8.276-8.84 11.4 4.216 14-4.624h9zm12.752 0h19.748l8.276-8.84-11.4 4.216-14-4.624h-9z" fill="#00000"/><text y="370" font-size="17" fill="red" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svg_two = '</text></svg>';

    constructor(string memory _tld) payable ERC721("Trapdoor Name Service", "TNS"){
        tld = _tld;
        console.log("Domains Contract");
    }

    

    function price(string calldata name) public pure returns(uint) {
    uint len = StringUtils.strlen(name);
    require(len > 0);
    if (len == 3) {
      return 5 * 10**16; 
    } else if (len == 4) {
      return 3 * 10**16; 
    } else {
      return 1 * 10**17;
    }
  }

    function register(string calldata _domainName) public payable{
        require(domainMap[_domainName] == address(0));
        if(!isValid(_domainName)) revert InvalidName(_domainName);
        uint _price = price(_domainName);
        require(msg.value >= _price, "Please pay more MATIC to register a domain");

        string memory name = string(abi.encodePacked(_domainName, '.', tld));

        string memory finalSvg = string(abi.encodePacked(svg_one, name , svg_two));

        uint256 newRecordId = _tokenIds.current();
  	    uint256 length = StringUtils.strlen(name);
		    string memory strLen = Strings.toString(length);

        console.log("%s has registered a domain %s with tokenId %s", msg.sender, _domainName, newRecordId);

            string memory json = Base64.encode(
            bytes(
            string(
            abi.encodePacked(
            '{"name": "',
            _domainName,
            '", "description": "A domain on the Trapdoor Name Service", "image": "data:image/svg+xml;base64,',
             Base64.encode(bytes(finalSvg)),
             '","length":"',
             strLen,
             '"}'
            )
          )
        )
    );

        string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

        console.log("\n--------------------------------------------------------");
        console.log("Final tokenURI", finalTokenUri);
        console.log("--------------------------------------------------------\n");

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);

        domainMap[_domainName] = msg.sender;

        domainNames[newRecordId] = _domainName;

        _tokenIds.increment();
        
    }

    function getAddress(string calldata _domainName) public view returns(address){
        if(domainMap[_domainName] == address(0)) revert Unregistered(_domainName);
        return domainMap[_domainName];
    }
    
    function storeRecord(string calldata _domainName, string calldata _spotifyLink) public {
        if(msg.sender != domainMap[_domainName]) revert Unauthorized();
        records[_domainName] = _spotifyLink;
        console.log("%s has put up a song on their domain %s", msg.sender, _domainName);
    }

    function getRecords(string calldata _domainName) public view returns(string memory){
        return records[_domainName];
    }

    function withdraw() public onlyOwner {
	  uint amount = address(this).balance;
	
	  (bool success, ) = msg.sender.call{value: amount}("");
	  require(success, "Failed to withdraw Matic");
    
    } 

    function getAllDomain() public view returns(string[] memory){
      console.log("Getting all domain names");
      string[] memory names = new string[](_tokenIds.current());
      for(uint i = 0; i < _tokenIds.current(); i++){
        names[i] = domainNames[i];
      }

      return names;
    }

    function isValid(string calldata _domainName) public pure returns(bool){
      return StringUtils.strlen(_domainName) >= 3 &&  StringUtils.strlen(_domainName) <= 10;
    }

}

