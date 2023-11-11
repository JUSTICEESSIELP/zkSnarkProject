-after writing the circuit you compile it to wasm and r1cs 
-then you use Groth 16 to create some randomness and link the final contribution to the r1cs file to produce the zkey .. 

 //  snarkjs powersoftau new bn128 12 ceremony_0000.ptau
 
 for more contribution to randomness in the real world you make others add their contributions and verify them 
 //   snarkjs powersoftau contribute ceremony_0000.ptau ceremony_0001.ptau
 TO VERIFY 
 // snarkjs powersoftau verify ceremony_final.ptau 
 PHASE 2 PREPARE TO GET THE FINAL POWERS OF TAU
 //snarkjs powersoftau prepare phase2z ceremony_0002.ptau ceremony_final.ptau

- link powersof Tau final file to the circuit with its r1cs
// snarkjs groth16 setup withdraw.r1cs ceremony_final.ptau setup_0000.zkey


-add some more randomness to the zkey after which you can ;

//snarkjs zkey contribute setup_0000.zkey setup_final.zkey
VERFIY THE VALIDITY OF THE ZKEY [1. circuit, ceremony, zkey]
//snarkjs zkey verify withdraw.r1cs ceremony_final.ptau setup_final.zkey


 get solidity verifier sol from it so that the inputs of the prover can be verified
// snarkjs zkey export solidityverifier setup_final.zkey Verifier.sol



-- now to the provers side they need to create an input json and with the wasm file from the circuit and 
