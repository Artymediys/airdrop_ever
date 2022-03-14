pragma ton-solidity >= 0.39.0;
pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;



contract ACheckOwner {
    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey());
        tvm.accept();
        _;
    }

    modifier checkOwner {
        require(msg.pubkey() == tvm.pubkey(), 107);
        _;
    }
}

