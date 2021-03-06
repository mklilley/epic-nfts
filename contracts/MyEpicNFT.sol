// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import {Base64} from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string private baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: Arial; font-size: 30px; }</style><rect width='100%' height='100%' fill='#2E8BC0' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever!
    string[] private firstWords = [
        "Easy",
        "Handsome",
        "Berserk",
        "Crabby",
        "Ruthless",
        "Faithful",
        "Macho",
        "Blushing",
        "Immense",
        "Misty",
        "Classy",
        "Wrathful",
        "Meaty",
        "Filthy",
        "Bouncy",
        "Giddy",
        "Tacky",
        "Happy",
        "Superb",
        "Clammy",
        "Deranged",
        "Ratchet",
        "Leaky",
        "Hungry",
        "Smelly",
        "Luscious"
    ];
    string[] private secondWords = [
        "Blood",
        "Breath",
        "Hair",
        "Soup",
        "Pie",
        "Shirt",
        "Death",
        "Wood",
        "Math",
        "Tongue",
        "Truth",
        "Map",
        "Pig",
        "Wolf",
        "Cat",
        "Dog",
        "Phone",
        "Bread",
        "Bath",
        "Tea",
        "Beer",
        "King",
        "Wife",
        "Chest",
        "Flight",
        "Cheek",
        "Mud",
        "Girl",
        "Hat",
        "Queen",
        "Lab",
        "Month",
        "Dirt",
        "Day"
    ];

    uint256 private maxNFT = 100;

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract. Woah!");
    }

    function pickRandomWord(
        uint256 tokenId,
        string memory seedWord,
        string[] memory wordArray
    ) private pure returns (string memory) {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked(seedWord, Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % wordArray.length;
        return wordArray[rand];
    }

    function random(string memory input) private pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getTotalNFTsMintedSoFar() public view returns (uint256) {
        return _tokenIds.current();
    }

    function getMaxNFTsMinted() public view returns (uint256) {
        return maxNFT;
    }

    function makeAnEpicNFT() public {
        // Maximum number of NFTs can be minted
        require(
            _tokenIds.current() <= maxNFT - 1,
            "All NFTs have been minted, sorry!"
        );

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomWord(
            newItemId,
            "FIRST_WORD",
            firstWords
        );
        string memory second = pickRandomWord(
            newItemId,
            "SECOND_WORD",
            secondWords
        );

        string memory third = second;

        while (
            keccak256(abi.encodePacked(third)) ==
            keccak256(abi.encodePacked(second))
        ) {
            third = pickRandomWord(newItemId, "THIRD_WORD", secondWords);
        }

        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(
            abi.encodePacked(baseSvg, combinedWord, "</text></svg>")
        );

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                // We set the title of our NFT as the generated word.
                combinedWord,
                '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                Base64.encode(bytes(finalSvg)),
                '"}'
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        // We'll be setting the tokenURI later!
        _setTokenURI(newItemId, finalTokenUri);

        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}
