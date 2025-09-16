Simple escrow contract. Flowchart - render in any Mermaid viewer:

graph TD

    subgraph "Setup"
        A[Start] --> B{Deploy ERC-20 & ERC-721 Tokens};
        B --> C{Deploy Escrow Contract};
        C --> D{Mint Tokens to Parties};
        D --> E[End Setup];
    end

    subgraph "Escrow Process"
        F[Buyer Approves Escrow for ERC-20] --> G[Buyer Calls createEscrow];
        G --> H[Buyer Calls depositFunds];
        H --> I{ERC-20 Locked in Escrow};
        I --> J[Escrow State: AwaitingDelivery];
        J --> K[Seller Approves Escrow for ERC-721];
        K --> L[Seller Calls deliverAsset];
        L --> M{Seller Transfers NFT to Escrow};
        M --> N{Escrow Contract Receives NFT};
        N --> O[onERC721Received Callback Triggered];
        O --> P[Escrow Transfers NFT to Buyer];
        P --> Q[Escrow Transfers ERC-20 to Seller];
        Q --> R[Escrow State: Completed];
    end


Installation:


1. npm init -y
... to install hardhat in the chosen directory (e.g., c:\escrow)
2. npm install --save-dev hardhat
3. npx hardhat --init
... select hardhat-2 to install
... select an empty javascript template (and then copy project files into it)
4. Add dependencies
   npm install @nomicfoundation/hardhat-toolbox
   npm install @openzeppelin/contracts

   ... this will add all you need to /node_modules directory (missing from the GIT project)
   
C:\escrow>npx hardhat test

<img width="887" height="853" alt="image" src="https://github.com/user-attachments/assets/4e5da802-b65e-448c-ae6f-021bc988e7ad" />


