// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import { FiatTokenV2_1 } from "../interface/IFiatTokenV2_1.sol";

contract FiatTokenV3 {
    /*
    $ forge inspect ./src/FiatTokenV2_1.sol:FiatTokenV2_1 storage --pretty
    | Name                 | Type                                            | Slot | Offset | Bytes | Contract                            |
    |----------------------|-------------------------------------------------|------|--------|-------|-------------------------------------|
    | _owner               | address                                         | 0    | 0      | 20    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | pauser               | address                                         | 1    | 0      | 20    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | paused               | bool                                            | 1    | 20     | 1     | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | blacklister          | address                                         | 2    | 0      | 20    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | blacklisted          | mapping(address => bool)                        | 3    | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | name                 | string                                          | 4    | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | symbol               | string                                          | 5    | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | decimals             | uint8                                           | 6    | 0      | 1     | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | currency             | string                                          | 7    | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | masterMinter         | address                                         | 8    | 0      | 20    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | initialized          | bool                                            | 8    | 20     | 1     | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | balances             | mapping(address => uint256)                     | 9    | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | allowed              | mapping(address => mapping(address => uint256)) | 10   | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | totalSupply_         | uint256                                         | 11   | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | minters              | mapping(address => bool)                        | 12   | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | minterAllowed        | mapping(address => uint256)                     | 13   | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | _rescuer             | address                                         | 14   | 0      | 20    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | DOMAIN_SEPARATOR     | bytes32                                         | 15   | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | _authorizationStates | mapping(address => mapping(bytes32 => bool))    | 16   | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | _permitNonces        | mapping(address => uint256)                     | 17   | 0      | 32    | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    | _initializedVersion  | uint8                                           | 18   | 0      | 1     | src/FiatTokenV2_1.sol:FiatTokenV2_1 |
    */
    address public _owner;
    address public pauser;
    bool public paused;
    address public blacklister;
    mapping(address => bool) public blacklisted;
    string public name;
    string public symbol;
    uint8 public decimals;
    string public currency;
    address public masterMinter;
    bool public initialized;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    uint256 public totalSupply_;
    mapping(address => bool) public minters;
    mapping(address => uint256) public minterAllowed;
    address public _rescuer;
    bytes32 public DOMAIN_SEPARATOR;
    mapping(address => mapping(bytes32 => bool)) public _authorizationStates;
    mapping(address => uint256) public _permitNonces;
    uint8 public _initializedVersion;

    address public immutable owner;
    mapping(address => bool) public whiteList;

    /**
    我不是用繼承，而是用 interface 的方式，
    所以只有 storage 有資料(因為 storage 是放在 proxy contract)
    其它，要用到的 function 都要在 logic contract 實作

    - 製作一個白名單
    - 只有白名單內的地址可以轉帳
    - 白名單內的地址可以無限 mint token
    - 如果有其他想做的也可以隨時加入
    */
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not contract owner");
        _;
    }

    function isWhiteList(address _addr) view external returns(bool){
      return whiteList[_addr];
    }

    function addWhiteList(address _addr) external onlyOwner {
        whiteList[_addr] = true;
    }

    function removeWhiteList(address _addr) external onlyOwner {
        whiteList[_addr] = false;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
