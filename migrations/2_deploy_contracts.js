var ESportToken = artifacts.require('./ESportToken.sol')
var ExchangeRate = artifacts.require('./ExchangeRate.sol')
var TokenSeller = artifacts.require('./TokenSeller.sol')

module.exports = function (deployer) {
  deployer.deploy(ESportToken)
  deployer.deploy(ExchangeRate)

  var token, rates
  deployer.then(function () {
    return ExchangeRate.deployed()
  }).then(function (instance) {
    rates = instance
    return ESportToken.deployed()
  }).then(function (instance) {
    token = instance
    return deployer.deploy(TokenSeller, token.address, rates.address)
  })
}
