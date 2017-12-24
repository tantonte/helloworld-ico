module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "110" // Match any network id
    },
    kovan: {
      host: "localhost",
      port: 8545,
      network_id: "42", // Match any network id
      from: "0x00670f9b9340515b9d6630d7899629501decF2ab"     
    },
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: "4", // Match any network id
      from: '0x7ddc0e773265867c514d5eca1b8ac496b46f6662'
    },
    main: {
      host: "localhost",
      port: 8545,
      network_id: '1'  // Ethereum public network
      // optional config values:
      // gas - Gas limit used for deploys. Default is 4712388
      // gasPrice - Gas price used for deploys. Default is 100000000000 (100 Shannon)
      // from - default address to use for any transaction Truffle makes during migrations
      // provider - web3 provider instance Truffle should use to talk to the Ethereum network.
      //          - if specified, host and port are ignored.
    }
  }
};
