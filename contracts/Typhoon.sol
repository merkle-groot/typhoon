// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './Deposit.sol';
import './Withdraw.sol';

contract Typhoon {
    Deposit dVerifier;
    Withdraw wVerifier;

    uint256 public key = 0;
    uint256 public amount = 0.11 ether; // Fixed amount in wei (1 ETH)
    uint256 public root;
    uint256[] public commitments;
    mapping(uint256 => bool) public nullifiers;

    constructor(
        address _depositVerifierContractAddr,
        address _withdrawVerifierContractAddr
    ) {
        dVerifier = Deposit(_depositVerifierContractAddr);
        wVerifier = Withdraw(_withdrawVerifierContractAddr);
        root = uint256(7191590165524151132621032034309259185021876706372059338263145339926209741311);
    }

    function deposit(
        uint256 _commitment,
        uint256 _root,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c
    ) public payable {
        // Verify the zk-proof for deposit
        uint256[4] memory input = [
            root, // rootOld
            _root, // rootNew
            _commitment,
            key + 1
        ];
        require(dVerifier.verifyProof(a, b, c, input), "zkProof deposit could not be verified");

        // Check deposit value
        require(msg.value == amount, "Deposit amount must be exactly 0.1 ETH");

        // Update state
        commitments.push(_commitment);
        root = _root;
        key += 1;
    }

    function getCommitments() public view returns (uint256[] memory, uint256, uint256) {
        return (commitments, root, key + 1);
    }

    function withdraw(
        address payable _address,
        uint256 nullifier,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c
    ) public {
        // Verify the zk-proof for withdrawal
        uint256[3] memory input = [
            nullifier,
            root,
            uint256(uint160(address(_address))) // Cast address to uint256
        ];
        require(wVerifier.verifyProof(a, b, c, input), "zkProof withdraw could not be verified");

        // Check nullifier validity
        require(useNullifier(nullifier), "Nullifier already used");

        // Transfer funds
        (bool success, ) = _address.call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    function useNullifier(uint256 nullifier) internal returns (bool) {
        if (nullifiers[nullifier]) {
            return false;
        }
        nullifiers[nullifier] = true;
        return true;
    }
}
