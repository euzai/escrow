const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Escrow", function () {
    let Escrow;
    let escrow;
    let ERC20Token;
    let erc20Token;
    let ERC721Token;
    let erc721Token;
    let buyer;
    let seller;
    let arbiter;

    const erc20Amount = ethers.parseUnits("100", 18);
    const erc721TokenId = 1;

    beforeEach(async function () {
        [buyer, seller, arbiter] = await ethers.getSigners();

        // Deploy mock ERC20 token
        ERC20Token = await ethers.getContractFactory("MockERC20");
        erc20Token = await ERC20Token.deploy("TestERC20", "T20");
        await erc20Token.waitForDeployment();

        // Deploy mock ERC721 token
        ERC721Token = await ethers.getContractFactory("MockERC721");
        erc721Token = await ERC721Token.deploy("TestERC721", "T721");
        await erc721Token.waitForDeployment();

        // Deploy the Escrow contract
        Escrow = await ethers.getContractFactory("Escrow");
        escrow = await Escrow.deploy(erc20Token.target, erc721Token.target);
        await escrow.waitForDeployment();

        // Mint tokens for the test
        await erc20Token.mint(buyer.address, erc20Amount);
        await erc721Token.safeMint(seller.address, erc721TokenId);
    });

    describe("Escrow Workflow", function () {
        it("should allow a buyer to create an escrow and deposit funds", async function () {
            // Buyer must approve the escrow contract first
            await erc20Token.connect(buyer).approve(escrow.target, erc20Amount);

            // Buyer creates the escrow
            const createEscrowTx = await escrow.connect(buyer).createEscrow(seller.address, erc20Amount, erc721TokenId);
            const receipt = await createEscrowTx.wait();
            
            // Correct way to read events from receipt logs in Hardhat
            const event = receipt.logs.find(log => log.address === escrow.target);
            const parsedLog = escrow.interface.parseLog(event);
            const escrowId = parsedLog.args.escrowId;

            const escrowDetails = await escrow.escrows(escrowId);
            
            expect(escrowDetails.buyer).to.equal(buyer.address);
            expect(escrowDetails.seller).to.equal(seller.address);
            expect(escrowDetails.erc20Amount).to.equal(erc20Amount);
            expect(escrowDetails.currentState).to.equal(0); // AwaitingPayment

            // Buyer deposits funds
            await escrow.connect(buyer).depositFunds(escrowId);
            const updatedEscrowDetails = await escrow.escrows(escrowId);

            expect(await erc20Token.balanceOf(escrow.target)).to.equal(erc20Amount);
            expect(updatedEscrowDetails.currentState).to.equal(1); // AwaitingDelivery
        });

        // ... (rest of the code is the same) ...

it("should allow a seller to deliver the asset and complete the escrow", async function () {
    // First, set up the escrow and deposit funds (this part is correct)
    await erc20Token.connect(buyer).approve(escrow.target, erc20Amount);
    
    const createEscrowTx = await escrow.connect(buyer).createEscrow(seller.address, erc20Amount, erc721TokenId);
    const receipt = await createEscrowTx.wait();
    const event = receipt.logs.find(log => log.address === escrow.target);
    const parsedLog = escrow.interface.parseLog(event);
    const escrowId = parsedLog.args.escrowId;

    await escrow.connect(buyer).depositFunds(escrowId);

    // New step: The seller must approve the escrow contract to transfer the NFT
    await erc721Token.connect(seller).approve(escrow.target, erc721TokenId);

    // Correct way to initiate the delivery: call the deliverAsset function
    await escrow.connect(seller).deliverAsset(escrowId);
    
    const finalEscrowDetails = await escrow.escrows(escrowId);
    
    // Now these assertions should pass
    expect(finalEscrowDetails.currentState).to.equal(2); // Completed
    expect(await erc20Token.balanceOf(seller.address)).to.equal(erc20Amount);
    expect(await erc721Token.ownerOf(erc721TokenId)).to.equal(buyer.address);
});

// ... (rest of the code is the same) ...
    });
});