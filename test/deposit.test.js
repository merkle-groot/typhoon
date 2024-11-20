const path = require("path");
const circom_tester = require("circom_tester").wasm;
const chai = require("chai");
const assert = chai.assert;
const circomlibjs = require("circomlibjs");
const { SMT } = circomlibjs;
const { buildSMT } = require("circomlibjs")
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
const p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(p);
const BN = require('bn.js');
const ffjavascript = require('ffjavascript');
const { utils } = ffjavascript;

const SMTMemDB = circomlibjs.SMTMemDb || circomlibjs.SMTMemDB;

function uint8ArrayToLittleEndianBigInt(uint8Array) {
    const reversedArray = Uint8Array.from(uint8Array).reverse();
    return "0x" + Buffer.from(reversedArray).toString("hex");
}

function toLittleEndian(number) {
    if (number > 0xFFFFFFFF || number < 0) {
        throw new Error("Number must fit in 32 bits (0 to 0xFFFFFFFF).");
    }

    // Reverse byte order
    const littleEndian =
        ((number & 0xFF) << 24) |
        ((number & 0xFF00) << 8) |
        ((number & 0xFF0000) >> 8) |
        ((number >>> 24) & 0xFF);

    return littleEndian >>> 0; // Ensure the result is unsigned
}


describe("Deposit Test", function () {
    this.timeout(100000); // Adjust the timeout as needed

    it("should correctly process a deposit", async () => {
        let poseidon = await circomlibjs.buildPoseidon();

        // Compile the circuit
        const circuit = await circom_tester(
            path.join(__dirname, "..", "circuits", "deposit.circom")
        );
        // await circuit.loadConstraints();

        const nLevels = 8;
        const secret = 1234567890;
        const key = "3";

        const coinCode = "3";
        const amount = "1000000000000000000";
        const initState = "0";

        const nullifier = poseidon([toLittleEndian(key)], initState);
        const nullifier_with_e = poseidon.F.e(nullifier);
        const nullifier_hex = uint8ArrayToLittleEndianBigInt(nullifier);
        console.log(nullifier, nullifier_with_e, nullifier_hex);
        console.log(toLittleEndian(2));

        // const commitment = poseidon([
        //     BigInt(coinCode),
        //     BigInt(amount),
        //     BigInt(secret),
        //     nullifier,
        // ]);



        // // Initialize Sparse Merkle Tree
        // const db = new SMTMemDB(poseidon.F);
        // const tree = await buildSMT(db, db.root);

        // // Insert initial value into the tree
        // let res = await tree.insert(1, 0);

        // let rootOld = tree.root;
        // // console.log(res);

        // // Insert the commitment into the tree
        // res = await tree.insert(2, commitment);
        // let rootNew = tree.root;
        // // console.log(res);

        // let siblings = res.siblings;
        // // Pad siblings to nLevels with zeros if necessary
        // while (siblings.length < nLevels) {
        //     siblings.push(Fr.zero);
        // }

        // console.log(
        //     res.oldRoot, hexString(res.oldRoot)
        // );

        // Prepare input for the circuit
        const input = {
            // coinCode: coinCode,
            // amount: amount,
            // oldRoot: hexString(res.oldRoot),
            // rootNew: hexString(res.newRoot),
            // commitment: hexString(commitment),
            key: toLittleEndian(key).toString(),
            nullifier: nullifier_hex,
            // secret: Fr.e(secret),
            // oldKey: res.isOld0 ? Fr.zero : hexString(res.oldKey),
            // oldValue: res.isOld0 ? Fr.zero : hexString(res.oldValue),
            // isOld0: res.isOld0 ? 1 : 0,
            // siblings: siblings,
        };

        // // Calculate the witness
        const witness = await circuit.calculateWitness(input, true);


        // Access the output (result is the last output signal defined)
        // console.log("Witness:", witness);


        // Check constraints
        // await circuit.checkConstraints(witness);

        // console.log(witness);

        // Assert the witness output matches the expected values
        // assert.equal(Fr.toObject(witness[0]), Fr.toObject(res.newRoot), "Root mismatch");
    });
});
