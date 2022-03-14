pragma ton-solidity >= 0.54.0;


interface ITransferTokenRootOwnershipCallback {

    function onTransferTokenRootOwnership(
        address oldOwner,
        address newOwner,
        address remainingGasTo,
        TvmCell payload
    ) external;

}
