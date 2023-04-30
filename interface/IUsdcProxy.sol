pragma solidity ^0.8.10;

interface FiatTokenProxy {
    event AdminChanged(address previousAdmin, address newAdmin);
    event Upgraded(address implementation);

    function admin() external view returns (address);
    function changeAdmin(address newAdmin) external;
    function implementation() external view returns (address);
    function upgradeTo(address newImplementation) external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}
