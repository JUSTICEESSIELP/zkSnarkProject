// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity 0.8.17;
// to prevent Reentrancy Attacks 
import "./ReentrancyGuard.sol";
// this is just a hashing procedure does several rounds of hashing based on an equation and then makes it computationally impossible  to reverse [the logarithmic problem ]
import "./MiMCSponge.sol";

contract Tornado is ReentrancyGuard {

    address verifier ;
    Hasher hasher;

    uint8 public treeLevel = 10;
    uint256 public denomination= 0.001 ether;


    uint256 public nextLeafIdx = 0;
    //tracking the root of the merkle tree that tracks deposits commentment hash
    mapping(uint256 => bool) public roots;

    // so what happens is that there is an array that when the deposit done stores the commitment hash and the  travereses with hashing till it gets to the root . so the lastlevel hash is to check a sister node if it hash a hash or not so that the parent node can produce a new hash either based on both the sister node and the incoming deposit commitment hash or the incoming commitment hash alone
    mapping(uint8 => uint256 )lastLevelHash;



// so what happens is that the user provides two 32 byte random string ..   [secret and the nullifer].. these two are then used with the circuit that uses the Pedersen hashing mechanism to output a commitment hash and a nullifier hash ... this mapping is to track that nullifierhash . this hash is also important when we are withdrawing because we can use it to know if the withdrawal has been done or not 
    mapping (uint256 => bool) public nulliferHashes;

// track which commitment hashes come to the merkle tree .. make sure there are not duplicate hashes to prevent hash collision 
    mapping(uint256 => bool) public commitments;


// default values for each level of the Merkle tree.. we generate 32 bytes ... uint256   remember to build a merkle tree you have to start with a non empty array with the power of 2 
uint256[10] levelDefaults = [
        23183772226880328093887215408966704399401918833188238128725944610428185466379,
        24000819369602093814416139508614852491908395579435466932859056804037806454973,
        90767735163385213280029221395007952082767922246267858237072012090673396196740,
        36838446922933702266161394000006956756061899673576454513992013853093276527813,
        68942419351509126448570740374747181965696714458775214939345221885282113404505,
        50082386515045053504076326033442809551011315580267173564563197889162423619623,
        73182421758286469310850848737411980736456210038565066977682644585724928397862,
        60176431197461170637692882955627917456800648458772472331451918908568455016445,
        105740430515862457360623134126179561153993738774115400861400649215360807197726,
        76840483767501885884368002925517179365815019383466879774586151314479309584255
    ];


    event Deposit(uint256 root, uint256[10] hashingPairings, uint8[10] pairDirection);

    event Withdrawal(address to , uint256 nullifierhash);



// so before we deploy this contract we deploy the MIMCSponge Contract to get the access to the functions that would enable us to hash our secret and nullifier.. 
//another things is that we need the verifier contract to verfy the commitment when withdrawing that would be produced from the Groth 16.. but the smart contract version from Groth 16 is old so we cannot instantiate it like the Hasher .. for the Hasher contract we built it and set its version to be the same of this one .. so we just use the address*****

// so we are using the deposit circom file to create the witness expresssion 

//we create a verfier smart contract from the withdrwal circom file to prove we are the right people to withdraw 

    constructor(address _hasher){
        hasher = Hasher(_hasher);
        //verifier = verifierAddress;

    

    }


    function deposit(uint256 _commitment) external payable nonReentrant{
        // make sure that the amount sent is allowed 
        require(msg.value == denomination, "Incorrect denomination of ETH");
        //make sure the incoming commitmenthash is not  a duplicate to prevent hash collision
        require(!commitments[_commitment], "Duplicate action");

        // we have a set number of txn allowed and this is based on  the level of our merkle tree if the level is 10 the number of nodes would be 2^10

            //                    Level 9:  #
            //                   /        \
            //         Level 8:  *          *
            //                   / \        / \
            //         Level 7:  +   -      =
            //                 / \ / \    / \
            //       Level 6:  #   *  /    *
            //                   / \ / \  / \
            //         Level 5:  *   ~  #    +
            //                 / \ / \ / \  / \
            //       Level 4:  ^   v  v    ^   v
            //               / \ / \ / \  / \ / \
            //     Level 3:  ~   =  -    +   *   #
            //               / \ / \ / \  / \ / \
            //     Level 2:  v   ^  ^    ~   =   +
            //             / \ / \ / \  / \ / \ / \
            //   Level 1:  *   ~  #    -   +
            //             / \ / \ / \  / \ / \ / \
            // Level 0:   ^   ~  =    +   -   *   *
            //            / \ / \ / \  / \ / \ / \ / \

            // each level has a commitment hash when the deposit is made so if the all the sister nodes of each level is full then we cannot deposit 
            require(nextLeafIdx < 2 ** treeLevel,"Cannot deposit merkle tree is full");

            uint256 newRoot;
            uint256[10] memory hashPairings;
            uint256[10] memory hashDirection;

           uint256 currentIndex = nextLeafIdx;
           uint256 left ;
           uint256 right;

           uint256 currentHash = _commitment;
           uint256[2] memory _ins; // current hash  + the proof  in an array so we pass it to the MiMc function to hash it 


            for(uint i =0; i< treeLevel; i++){
                if(currentIndex % 2 == 0){
                    // this that our index is an even number and so its on the left .. so we take the right value and update the hashPairing with that to be read to hash it with sponge
                    left = currentHash;
                    right= levelDefaults[i];
                    // even numbers is 0  
                    hashDirection[i] = 0;
                    hashPairings[i] = levelDefaults[i];



                }else{
                    right = currentHash;
                    left = levelDefaults[i];
                    // since the index is an odd number its on the right 
                    hashDirection[i] = 1;
                    hashPairings[i] = levelDefaults[i];
                    
                }
                 _ins[0] = left;
                _ins[1] = right;
           (uint256 h) = hasher.MiMC5Sponge{gas:150000}(_ins,  _commitment);
           
                currentIndex= currentIndex /2;
                   currentHash = h;
                
    
            }

            newRoot = currentHash;
            roots[newRoot] = true;
            nextLeafIdx+=1;

            commitments[_commitment] = true;

        


    }
}