# Reversing The EVM: Raw Calldata and Bytecode to navigate the functions or opcodes

## A POC (Proof Of Concept)

### Understanding the concepts

1. **Calldata** : refers to the encoded parameters sent to functions or smartcontracts on the blockchain. Each calldata piece  is 32-bytes long or 64 characters. Its of two types;
 **Static Calldata** which is straightforward and whose parameters dont change in size during execution. **Dynamic Calldata** on the other hand is more complex , its size changes during execution and reading it can be difficult initially.

#### Encoding and decoding calldata
    - To encode types, they are passed into the `abi.encode(parameters)` to generate the raw calldata
    - And for a specific function , the `abi.encodeWithSelector(selector, parameters)` allows you encode calldata for a specific interfaced function, similar to passing in the function and its parameters directly
    - A good conceptual proof is : 
    ```=solidity
    interface A {
      function transfer(uint256[] memory ids, address to) virtual external;
    }

    contract B {
      function a(uint256[] memory ids, address to) external pure returns(bytes memory) {
        return abi.encodeWithSelector(A.transfer.selector, ids, to);
      }
    }
- The `.selector` method in UniswapV2 generates a 4-byte identifier for functions, facilitating calldata communication with the Ethereum Virtual Machine and enabling flashswaps. Alternatively, `abi.encodePacked(...)` efficiently combines dynamic variables but lacks collision prevention, suitable only when parameter types and lengths are certain.
    - Running the function with an address and an array of value would return a byte array which is  basically an encoded form of this data in a bytes array. This would allow the calling of a contract that implements the A interface

- If you made calldata with `abi.encode(...)`, you can read it with `abi.decode(...)`. Like this:


```(uint256 a, uint256 b) = abi.decode(data, (uint256, uint256));```




Here, data is the calldata.


### Steps in reading static calldata
a. Split `0x` from the decoded value 
b. Split each line into 64-characters (32-byte) parts
c. Static variables are fixed data types {`uint`, `int`, `address`, `bool`, `bytes1` , `bytes32`, and some `tuples`}

Splitting it this way allows to read the function parameters

### Functions
a. The hash of a function plus its type using keccak256 would return a 32-byte hash  
b. Strip the `0x`
c. To get the function signature , use the 4-byte(8-characters) after the `0x` prefix.
d. If a function is called with static data, we have `0x..<functionHash>paddedwith0...... till static data`
    
    

- Reading Static Variables

    Static variables are simple types like uints, ints, address, bool, bytes1 to bytes32, and tuples.

    For example, if we have this contract:

    ```=solidity
    contract ReadCalldata {
    function readData(uint256 num, address addr) external pure returns (uint256, address) {
        return (num, addr);
    }} 
    ```


And we use these parameters:

    num: 23
    address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

We get this calldata: 
```0x69168c1d00000000000000000000000000000000000000000000000000000000000000170000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4.```

To read it, we split it into 32 byte parts:

```=solidity
0x
//function name
69168c1d
// uint256
0000000000000000000000000000000000000000000000000000000000000017
// address
0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4
```

Now we see we get the function name in hex, the first 32-bytes is the uint256 num and the second 32-bytes is the address addr.



**Dynamic Variables** ; on the other hand are non-fixed size types including `bytes, string ,dynamic and fixed array types`
- The structure usually starts with :
i. **Offset:** hexadecimal representation of where the dynamic type begins, a good example is `20` which means `32 bytes`, once we reach the offset , a smaller number represents the length of the type.
ii. In arrays , the length represents number of elements contained in the array 

- 1st 32 Bytes -> Offset
- 2nd 32 Bytes -> Length
- The rest are elements 

For example, if we have this contract:

```=solidity
    contract ReadDynamicCalldata {
    function readArray(uint256[] calldata arr) external pure returns (uint256[] memory) {
        return arr;
    }
}
```


And we use these parameters when calling the readArray function:

    `[ 23,47,24]`
    
We get this calldata:

    0xc77f7f64000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000017000000000000000000000000000000000000000000000000000000000000002f0000000000000000000000000000000000000000000000000000000000000018
    
To read it, we split it into 32 byte parts:
```=solidity
0x
//function name
77f7f64

// offset
0000000000000000000000000000000000000000000000000000000000000020
//length of array
0000000000000000000000000000000000000000000000000000000000000003
//first element of the array
0000000000000000000000000000000000000000000000000000000000000017
//second element of the array
000000000000000000000000000000000000000000000000000000000000002f
//third element of the array
0000000000000000000000000000000000000000000000000000000000000018
```
**N.B:** These types start on the left hand side of the calldata unlike everything else on the right hand side.
- The `20` in hexadecimal refers to the 32 bytes offset you skip from the start
- The `03` also points to the length of our input array
- Converting the rest back to decimal reverts back to our initial decimal input

- This article was inspired by [Degatchi's  Article here](https://degatchi.com/articles/reading-raw-evm-calldata)

