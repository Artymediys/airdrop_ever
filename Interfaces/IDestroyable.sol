pragma ton-solidity >= 0.54.0;

interface IDestroyable {
    function destroy(address remainingGasTo) external;
}
