pragma circom 2.0.0;

// Include necessary libraries
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";
include "../node_modules/circomlib/circuits/smt/smtverifier.circom";

template Deposit(nLevels) {
    // Public Inputs
    signal input coinCode;
    signal input amount;
    signal input oldRoot;
    signal input rootNew;
    signal input commitment;
    signal input key;

    // Private Inputs
    signal input secret;
    signal input oldKey;
    signal input oldValue;
    signal input isOld0; // 1 if old value is 0 (non-existent)
    signal input siblings[nLevels];

    // Poseidon Hash for Nullifier
    component nullifierCmp = Poseidon(2);
    nullifierCmp.inputs[0] <== key;
    nullifierCmp.inputs[1] <== secret;
    signal nullifier;
    nullifier <== nullifierCmp.out;

    // Poseidon Hash for Commitment
    component hash = Poseidon(4);
    hash.inputs[0] <== coinCode;
    hash.inputs[1] <== amount;
    hash.inputs[2] <== secret;
    hash.inputs[3] <== nullifier;
    signal newValue;
    newValue <== hash.out;

    // Check Commitment
    component comCheck = IsEqual();
    comCheck.in[0] <== newValue;
    comCheck.in[1] <== commitment;
    comCheck.out === 1;

    // // SMT Verification and Update
    // component smtVerifier = SMTProcessor(nLevels);
    // smtVerifier.oldRoot <==  oldRoot;
    // for (var i = 0; i < nLevels; i++) {
    //     smtVerifier.siblings[i] <== siblings[i];
    // }
    // smtVerifier.oldKey <==  oldKey;
    // smtVerifier.oldValue <==  oldValue;
    // smtVerifier.isOld0 <==  isOld0;
    // smtVerifier.newKey <==  key;
    // smtVerifier.newValue <==  commitment;
    // smtVerifier.fnc <==  [0, 1];

    // // Get the new root from smtVerifier
    // signal updatedRoot;
    // updatedRoot <== smtVerifier.newRoot;

    // // Check that the updated root matches the provided rootNew
    // component rootCheck = IsEqual();
    // rootCheck.in[0] <== updatedRoot;
    // rootCheck.in[1] <== rootNew;
    // rootCheck.out === 1;
}

// Instantiate the main component
component main = Deposit(8);
