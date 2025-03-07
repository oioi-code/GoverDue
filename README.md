# 📜 GoverDue: Decentralized Government Management System

🚀 **GoverDue** is a blockchain-based **decentralized governance system** designed to manage **government agencies, public funds, citizen petitions, voting, and contracts**. It ensures **transparency, accountability, and efficiency** in governance by leveraging **smart contracts on the Ethereum blockchain**.

---

## 📂 Contracts Overview  

GoverDue consists of **six main contracts** and a **deployer contract**, each handling a specific aspect of government administration.  

| Contract Name            | Description |
|-------------------------|-------------|
| `GoverDue.sol`          | Core contract for managing government agencies, policy proposals, and citizen participation. |
| `GoverDueFunds.sol`     | Tracks government budgets, expenditures, and fund transfers between agencies. |
| `GoverDueIdentity.sol`  | Provides decentralized identity verification for government officials and citizens. |
| `GoverDuePetition.sol`  | Allows citizens to create and support petitions for government review. |
| `GoverDueContracts.sol` | Manages government contracts, contractor assignments, and payments. |
| `GoverDueVoting.sol`    | Implements decentralized voting for elections, referendums, and policy decisions. |
| `GoverDueDeployer.sol`  | Deploys all GoverDue contracts in a single transaction and stores their addresses. |

---

## 🔧 Deployment Guide  

### 1️⃣ Install Dependencies  
Ensure you have **Node.js, Hardhat, and Solidity Compiler** installed:  
```sh
npm install -g hardhat
```

📜 Smart Contract Functions
🔹 GoverDue.sol - Government Management

    addAgency(name, description, head) → Add a new government agency
    proposePolicy(title, description) → Propose a government policy
    registerCitizen(address) → Register a citizen for participation
    votePolicy(policyId) → Citizens can vote on policies

🔹 GoverDueFunds.sol - Financial Tracking

    registerAgency(name, head, initialFunds) → Register a new agency with a budget
    allocateFunds(agencyId, amount) → Allocate funds to a government agency
    spendFunds(agencyId, amount) → Track expenditures by an agency
    transferFunds(fromAgency, toAgency, amount) → Transfer funds between agencies

🔹 GoverDueIdentity.sol - Identity Management

    registerIdentity(user, name, role) → Assign an identity to a user
    updateIdentity(user, name, role) → Update a user’s identity details
    revokeIdentity(user) → Remove an identity from the system

🔹 GoverDuePetition.sol - Citizen Petitions

    createPetition(title, description) → Citizens create a petition
    supportPetition(petitionId) → Other citizens can support the petition
    reviewPetition(petitionId, approved) → Government reviews and approves/rejects petitions

🔹 GoverDueContracts.sol - Government Contracts

    createContract(title, description, agency, budget) → Create a contract for public projects
    assignContractor(contractId, contractor) → Assign a contractor to a government project
    releaseFunds(contractId, amount) → Release payment to a contractor

🔹 GoverDueVoting.sol - Decentralized Voting

    createVote(title, description, voteType, duration) → Create a new election, referendum, or policy vote
    addCandidate(voteId, name) → Add candidates to an election
    castVote(voteId, candidateIndex) → Citizens cast votes
    concludeVote(voteId) → Close voting and finalize results

🔹 GoverDueDeployer.sol - Deployment

    Deploys all GoverDue-related contracts in a single transaction
    Stores contract addresses for easy reference
