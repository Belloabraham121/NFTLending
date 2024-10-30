// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "forge-std/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/facets/NFTLendingFacet.sol";
import "../contracts/interfaces/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract MockNFT is ERC721 {
    uint256 private _tokenIdCounter;

    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter++;
        _mint(to, tokenId);
        return tokenId;
    }
}

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MTK") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}

contract DiamondDeployer is Test, IDiamondCut {
   
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    NFTLendingFacet lendingFacet;

    
    MockNFT mockNFT;
    MockERC20 mockToken;

    
    address borrower;
    address lender;
    uint256 tokenId;

    function setUp() public {
        deployDiamond();
        setupMockTokens();
        setupTestAccounts();
    }

    function deployDiamond() public {
        
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        lendingFacet = new NFTLendingFacet();

       
        FacetCut;

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(lendingFacet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("NFTLendingFacet")
            })
        );

     
        IDiamondCut(address(diamond)).diamondCut(cut, address(lendingFacet), abi.encodeWithSignature("initializeLendingFacet()"));
    }

    function setupMockTokens() internal {
      
        mockNFT = new MockNFT();
        mockToken = new MockERC20();
    }

    function setupTestAccounts() internal {
        
        borrower = makeAddr("borrower");
        lender = makeAddr("lender");

       
        vm.deal(borrower, 100 ether);
        vm.deal(lender, 100 ether);
        mockToken.transfer(lender, 1000 * 10**18);

        
        vm.prank(borrower);
        tokenId = mockNFT.mint(borrower);
    }

    
    
    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string;
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
