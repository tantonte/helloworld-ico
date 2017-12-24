var Seller = artifacts.require('./TokenSeller.sol')

contract('TokenSeller', async function (accounts) {
  it ('should trade token correctly', async function () {
    const seller = await Seller.deployed()
    const token = await seller.token.call(accounts[0])
    const whitelist = await seller.whitelist.call(accounts[0])
    // Get initial balances of first and second account.
    var owner = accounts[0]
    var account = accounts[1]
    if (!account) assert.fail('accountOne not existed')

    var amount = 1

    var startingBalance = await token.balanceOf.call(account)

    await whitelist.add([account], {from: owner})

    // FIXME: cannot send ether here in test code. =_=

    var endingBalance = await token.balanceOf.call(account)

    assert.equal(
      endingBalance.toNumber(),
      startingBalance.toNumber() + (amount * 1000),
      'Amount wasn\'t correctly taken from the sender'
    )
  })
})
