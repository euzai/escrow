// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract Escrow is Ownable, ERC721Holder {
    IERC20 public erc20Token;
    IERC721 public erc721Token;

    enum State { AwaitingPayment, AwaitingDelivery, Completed }

    struct EscrowDetails {
        address payable buyer;
        address payable seller;
        uint256 erc20Amount;
        uint256 erc721TokenId;
        State currentState;
    }

    mapping(uint256 => EscrowDetails) public escrows;
    uint256 private escrowIdCounter;

    event EscrowCreated(uint256 indexed escrowId, address indexed buyer, address indexed seller, uint256 erc20Amount, uint256 erc721TokenId);
    event EscrowFundsDeposited(uint256 indexed escrowId, address indexed buyer, uint256 amount);
    event EscrowAssetDelivered(uint256 indexed escrowId, address indexed seller, uint256 erc721TokenId);
    event EscrowCompleted(uint256 indexed escrowId, address indexed buyer, address indexed seller);

    constructor(address _erc20Token, address _erc721Token) Ownable(msg.sender) {
        erc20Token = IERC20(_erc20Token);
        erc721Token = IERC721(_erc721Token);
    }

    /// @notice Creates an escrow and requires the buyer to approve the contract to spend the ERC-20 tokens.
    /// @param _seller The address of the seller.
    /// @param _erc20Amount The amount of ERC-20 tokens the buyer will deposit.
    /// @param _erc721TokenId The ID of the ERC-721 token being sold.
    function createEscrow(address payable _seller, uint256 _erc20Amount, uint256 _erc721TokenId) external returns (uint256) {
        require(_seller != address(0), "Seller cannot be the zero address.");
        require(_seller != msg.sender, "Seller cannot be the buyer.");
        require(erc20Token.allowance(msg.sender, address(this)) >= _erc20Amount, "Buyer has not approved sufficient ERC-20 tokens.");

        escrowIdCounter++;
        uint256 escrowId = escrowIdCounter;

        escrows[escrowId] = EscrowDetails({
            buyer: payable(msg.sender),
            seller: _seller,
            erc20Amount: _erc20Amount,
            erc721TokenId: _erc721TokenId,
            currentState: State.AwaitingPayment
        });

        emit EscrowCreated(escrowId, msg.sender, _seller, _erc20Amount, _erc721TokenId);
        return escrowId;
    }

    /// @notice Buyer deposits the ERC-20 funds into the escrow.
    /// @param _escrowId The ID of the escrow to deposit funds for.
    function depositFunds(uint256 _escrowId) external {
        EscrowDetails storage escrow = escrows[_escrowId];
        require(escrow.buyer == msg.sender, "Only the buyer can deposit funds.");
        require(escrow.currentState == State.AwaitingPayment, "Funds have already been deposited or escrow is invalid.");

        bool success = erc20Token.transferFrom(msg.sender, address(this), escrow.erc20Amount);
        require(success, "ERC-20 transfer failed.");

        escrow.currentState = State.AwaitingDelivery;
        emit EscrowFundsDeposited(_escrowId, msg.sender, escrow.erc20Amount);
    }

    /// @notice Seller transfers the ERC-721 token to the contract.
    /// @param _escrowId The ID of the escrow to deliver the token for.
    function deliverAsset(uint256 _escrowId) external {
        EscrowDetails storage escrow = escrows[_escrowId];
        require(escrow.seller == msg.sender, "Only the seller can deliver the asset.");
        require(escrow.currentState == State.AwaitingDelivery, "Escrow is not in the delivery state.");

        address sellerAddress = msg.sender;
        erc721Token.safeTransferFrom(sellerAddress, address(this), escrow.erc721TokenId);
        
        emit EscrowAssetDelivered(_escrowId, msg.sender, escrow.erc721TokenId);
    }

    /// @notice This function is called by the ERC-721 contract when a token is received by this contract.
    /// @dev This callback function is required for the ERC721Holder interface.
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public override returns (bytes4) {
        // We need to find which escrow this token delivery corresponds to.
        // For simplicity, we will assume a single-use contract or find the correct escrow.
        for (uint256 i = 1; i <= escrowIdCounter; i++) {
            if (escrows[i].erc721TokenId == tokenId && escrows[i].seller == from && escrows[i].currentState == State.AwaitingDelivery) {
                // Transfer ERC-721 to the buyer
                erc721Token.safeTransferFrom(address(this), escrows[i].buyer, tokenId);
                
                // Release ERC-20 funds to the seller
                bool success = erc20Token.transfer(escrows[i].seller, escrows[i].erc20Amount);
                require(success, "ERC-20 transfer to seller failed.");

                escrows[i].currentState = State.Completed;
                emit EscrowCompleted(i, escrows[i].buyer, escrows[i].seller);
                return ERC721Holder.onERC721Received.selector;
            }
        }
        
        // If no matching escrow is found, we should revert to prevent tokens from being locked.
        revert("ERC721 token received, but no matching escrow found.");
    }
}