// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
// import { Proxy } from "../src/FiatTokenProxy.sol";
// import { FiatTokenV1, FiatTokenV2 } from "../src/FiatTokenV2.sol";
// import { FiatTokenV2_1 } from "../src/FiatTokenV2_1.sol";

contract UsdcTest is Test {
    /**
    請假裝你是 USDC 的 Owner，嘗試升級 usdc，並完成以下功能
    - 製作一個白名單
    - 只有白名單內的地址可以轉帳
    - 白名單內的地址可以無限 mint token
    - 如果有其他想做的也可以隨時加入
    */

    /**
      === [ 先來嘗試升級 usdc ] ===
      1. 已有 proxy 的合約地址
      2. 已有 admint 的地址
      3.
     */

    uint mainnetFork;
    string MAINNET_RPC_URL = "https://eth-mainnet.g.alchemy.com/v2/HVFSJbF2lktX-HJntcTStYyuJg1orfYg";
    address USDC_TOKEN_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address usdc_admin;
    bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;


    // usdc proxy contract : https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48

    function setUp() public {
      mainnetFork = vm.createFork(MAINNET_RPC_URL);
      vm.selectFork(mainnetFork);
      /**
       * vm.load 抓出來的是一個 slot
       * slot 的長度為 32 bytes = uint256 的長度
       * 因此可以轉型為 uint256
       * uint大的，又可以轉成小的，所以把 uint256 -> uint160
       * 轉成 uint160 是因為 address 是 20 bytes，uint160 = 20 bytes
       * 這邊的操作主要就是透過 uint 轉來轉去，來達到抓取想要的資料 part 的效果
       */
      usdc_admin = address(uint160(uint256(vm.load(USDC_TOKEN_ADDRESS, ADMIN_SLOT)))); // 0x807a96288A1A408dBC13DE2b1d087d10356395d2
    }

    function testUpgrade() public {

    }

    function testWhiteList() public {
      vm.startPrank(usdc_admin);
    }
}
