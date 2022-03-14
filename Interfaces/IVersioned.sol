pragma ton-solidity >= 0.54.0;


interface IVersioned {
    function version() external view responsible returns (uint32);
}
