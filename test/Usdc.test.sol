// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


import "forge-std/Test.sol";

import { IFiatTokenProxy } from "../interface/IFiatTokenProxy.sol";
// import { FiatTokenV2_1 } from "../interface/IFiatTokenV2_1.sol";
import { FiatTokenV3 } from "../src/FiatTokenV3.sol";

contract UsdcTest is Test {
    /**
    請假裝你是 USDC 的 Owner，嘗試升級 usdc，並完成以下功能
    - 製作一個白名單
    - 只有白名單內的地址可以轉帳
    - 白名單內的地址可以無限 mint token
    - 如果有其他想做的也可以隨時加入
    */

    uint mainnetFork;
    string MAINNET_RPC_URL = "https://eth-mainnet.g.alchemy.com/v2/HVFSJbF2lktX-HJntcTStYyuJg1orfYg";
    address USDC_TOKEN_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;
    bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;
    address usdc_admin;
    address implementation;
    // FiatTokenV2_1 usdcv2_1;
    FiatTokenV3 usdcv3;
    IFiatTokenProxy usdcProxy;
    address usdc_owner = makeAddr("usdc_owner");
    address w_user1 = makeAddr("w_user1");
    address w_user2 = makeAddr("w_user2");
    address w_user3 = makeAddr("w_user3");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

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
        usdc_admin = address(uint160(uint256(vm.load(USDC_TOKEN_ADDRESS, ADMIN_SLOT))));              // 0x807a96288A1A408dBC13DE2b1d087d10356395d2
        implementation = address(uint160(uint256(vm.load(USDC_TOKEN_ADDRESS, IMPLEMENTATION_SLOT)))); // 0xa2327a938Febf5FEC13baCFb16Ae10EcBc4cbDCF
        usdcProxy = IFiatTokenProxy(USDC_TOKEN_ADDRESS);

        // 測一下用 v2 能不能抓到正確的 balance
        // usdcv2_1 = FiatTokenV2_1(USDC_TOKEN_ADDRESS);
        // uint256 coinbase_balance = usdcv2_1.balanceOf(0xA9D1e08C7793af67e9d92fe308d5697FB81d3E43);
        // console.log("coinbase_balance in v2_1", coinbase_balance);
    }

    function testUpgrade() public {
        vm.startPrank(usdc_admin);
        address newLogicContractAddr = upgrade();
        address imp = usdcProxy.implementation();
        vm.stopPrank();
        // 檢查剛 depoly 的 logic contract 地址，跟 proxy contract 的 implementation 有沒有相同，兩者相同  = 升級成功
        assertEq(newLogicContractAddr, imp);

        // address aa = usdcv3.owner();
        // console.log("usdcv3.owner", aa);

        // 測一下能不能用 v3 抓到正確的 balance
        // uint256 coinbase_balance = usdcv3.balanceOf(0xA9D1e08C7793af67e9d92fe308d5697FB81d3E43);
        // console.log("coinbase_balance in v3", coinbase_balance);

        string memory symbol = usdcv3.symbol();
        // 測試在使用 v3 能不能抓到 symbol，可以的話，表示 logic contract 有置換成功
        assertEq(symbol, "USDC");
    }

    function testWhiteList() public {
        vm.startPrank(usdc_admin);
        upgrade();
        vm.stopPrank();

        vm.startPrank(usdc_owner);
        // 將 w_user1 加入白名單，確認 w_user1 有在白名單中
        usdcv3.addWhiteList(w_user1);
        assertEq(usdcv3.isWhiteList(w_user1), true);

        // 將 w_user1 從白名單移除，確認 w_user1 沒有在白名單中
        usdcv3.removeWhiteList(w_user1);
        assertEq(usdcv3.isWhiteList(w_user1), false);

        // 沒有將 user1 加入白名單中，確認 user1 沒有在白名單中
        assertEq(usdcv3.isWhiteList(user1), false);
        vm.stopPrank();
    }

    // 設成 uint256 的話， totalSupply 會有溢位的錯誤，所以用 uint128 測
    function testWhiteListMint(uint128 _amount) public {
        // 升級合約
        vm.startPrank(usdc_admin);
        upgrade();
        vm.stopPrank();

        // 添加白名單
        vm.startPrank(usdc_owner);
        usdcv3.addWhiteList(w_user1);
        usdcv3.addWhiteList(w_user2);
        usdcv3.addWhiteList(w_user3);
        vm.stopPrank();

        uint256 userBalance;
        // 多 mint 個幾次，檢查有無錯誤
        for (uint i = 0; i < 10; i++) {
          userBalance = usdcv3.balanceOf(w_user1);
          vm.prank(w_user1);
          usdcv3.mint(_amount);
          // 剛 mint 了 _amount 數量，檢查是否有 mint 出來
          assertEq(usdcv3.balanceOf(w_user1), userBalance + _amount);
        }

        // 非白名單 user 不能 mint
        userBalance = 0;
        vm.prank(user1);
        userBalance = usdcv3.balanceOf(user1);
        vm.expectRevert("not whitelist"); // 非白名單 user mint 的話，會有錯誤
        usdcv3.mint(_amount);
        assertEq(usdcv3.balanceOf(user1), userBalance); // 並且 mint 完後，balance 不會增加
    }


    function testWhiteListTransfer() public {
        // 升級合約
        vm.startPrank(usdc_admin);
        upgrade();
        vm.stopPrank();

        // 添加白名單
        vm.startPrank(usdc_owner);
        usdcv3.addWhiteList(w_user1);
        usdcv3.addWhiteList(w_user2);
        usdcv3.addWhiteList(w_user3);
        vm.stopPrank();

        // mint 一點錢出來用
        vm.prank(w_user1);
        usdcv3.mint(55555);

        uint256 balance1;
        uint256 balance2;
        uint256 transferAmount = 11111;

        // 白名單轉給白名單
        balance1 = usdcv3.balanceOf(w_user1);
        balance2 = usdcv3.balanceOf(w_user2);
        vm.prank(w_user1);
        usdcv3.transfer(w_user2, transferAmount);
        // 檢查 轉出者 的 balance 有無減少
        assertEq(usdcv3.balanceOf(w_user1), balance1 - transferAmount);
        // 檢查 收到者 的 balance 有無增加
        assertEq(usdcv3.balanceOf(w_user2), balance2 + transferAmount);

        // 白名單轉給非白名單
        balance1 = usdcv3.balanceOf(w_user1);
        balance2 = usdcv3.balanceOf(user1);
        vm.prank(w_user1);
        usdcv3.transfer(user1, transferAmount);
        // 檢查 轉出者 的 balance 有無減少
        assertEq(usdcv3.balanceOf(w_user1), balance1 - transferAmount);
        // 檢查 收到者 的 balance 有無增加
        assertEq(usdcv3.balanceOf(user1), balance2 + transferAmount);


        // 非白名單轉給白名單
        balance1 = usdcv3.balanceOf(user1);
        balance2 = usdcv3.balanceOf(w_user1);
        vm.prank(user1);
        vm.expectRevert("not whitelist"); // 非白名單 user transfer 的話，會有錯誤
        usdcv3.transfer(w_user1, transferAmount);
        // 檢查 轉出者 的 balance，不應該有變動 (因為是非白名單，無法 transfer)
        assertEq(usdcv3.balanceOf(user1), balance1 );
        // 檢查 收到者 的 balance，不應該有變動 (因為是非白名單，無法 transfer)
        assertEq(usdcv3.balanceOf(w_user1), balance2 );


        // 非白名單轉給非白名單
        balance1 = usdcv3.balanceOf(user1);
        balance2 = usdcv3.balanceOf(user2);
        vm.prank(user1);
        vm.expectRevert("not whitelist"); // 非白名單 user transfer 的話，會有錯誤
        usdcv3.transfer(user2, transferAmount);
        // 檢查 轉出者 的 balance，不應該有變動 (因為是非白名單，無法 transfer)
        assertEq(usdcv3.balanceOf(user1), balance1 );
        // 檢查 收到者 的 balance，不應該有變動 (因為是非白名單，無法 transfer)
        assertEq(usdcv3.balanceOf(user2), balance2 );
    }

    /**
      === [ 先來嘗試升級 usdc ] ===
      事前準備：
        1. 要有 proxy 的合約地址
        2. 要有 admint 的地址
        3. 要有 usdc proxy 的 interface，才能去 call 裡面的 function，可以使用這個 abi to interface 工具： https://gnidan.github.io/abi-to-sol/
        4. 升級後的合約 storage layout 要跟 usdc proxy 一樣嗎(?)
        5. 升級後的合約，要繼承前一個版本嗎(?)
      實作步驟：
        1. depoly v3 contract
        2. 執行 usdcProxy.upgradeTo(newImplementation)
     */

    function upgrade() public returns(address){
      FiatTokenV3 tempDeployContract = new FiatTokenV3(usdc_owner);
      usdcProxy.upgradeTo(address(tempDeployContract));
      usdcv3 = FiatTokenV3(address(usdcProxy));
      return address(tempDeployContract);
    }
}
