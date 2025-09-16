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


  Escrow
    Escrow Workflow
      √ should allow a buyer to create an escrow and deposit funds
      √ should allow a seller to deliver the asset and complete the escrow


  2 passing (186ms)

·············································································································
|  Solidity and Network Configuration                                                                       │
························|·················|···············|·················|································
|  Solidity: 0.8.20     ·  Optim: false   ·  Runs: 200    ·  viaIR: false   ·     Block: 30,000,000 gas     │
························|·················|···············|·················|································
|  Methods                                                                                                  │
························|·················|···············|·················|················|···············
|  Contracts / Methods  ·  Min            ·  Max          ·  Avg            ·  # calls       ·  usd (avg)   │
························|·················|···············|·················|················|···············
|  Escrow               ·                                                                                   │
························|·················|···············|·················|················|···············
|      createEscrow     ·              -  ·            -  ·        147,860  ·             4  ·           -  │
························|·················|···············|·················|················|···············
|      deliverAsset     ·              -  ·            -  ·        130,735  ·             1  ·           -  │
························|·················|···············|·················|················|···············
|      depositFunds     ·              -  ·            -  ·         82,983  ·             2  ·           -  │
························|·················|···············|·················|················|···············
|  MockERC20            ·                                                                                   │
························|·················|···············|·················|················|···············
|      approve          ·              -  ·            -  ·         46,964  ·             2  ·           -  │
························|·················|···············|·················|················|···············
|      mint             ·              -  ·            -  ·         68,959  ·             2  ·           -  │
························|·················|···············|·················|················|···············
|  MockERC721           ·                                                                                   │
························|·················|···············|·················|················|···············
|      approve          ·              -  ·            -  ·         49,033  ·             1  ·           -  │
························|·················|···············|·················|················|···············
|      safeMint         ·              -  ·            -  ·         72,029  ·             2  ·           -  │
························|·················|···············|·················|················|···············
|  Deployments                            ·                                 ·  % of limit    ·              │
························|·················|···············|·················|················|···············
|  Escrow               ·              -  ·            -  ·      1,829,926  ·         6.1 %  ·           -  │
························|·················|···············|·················|················|···············
|  MockERC20            ·              -  ·            -  ·        950,932  ·         3.2 %  ·           -  │
························|·················|···············|·················|················|···············
|  MockERC721           ·              -  ·            -  ·      1,861,409  ·         6.2 %  ·           -  │
························|·················|···············|·················|················|···············
|  Key                                                                                                      │
·············································································································
|  ◯  Execution gas for this method does not include intrinsic gas overhead                                 │
·············································································································
|  △  Cost was non-zero but below the precision setting for the currency display (see options)              │

<img width="887" height="853" alt="image" src="https://github.com/user-attachments/assets/4e5da802-b65e-448c-ae6f-021bc988e7ad" />

·············································································································
|  Toolchain:  hardhat                                                                                      │
·············································································································
