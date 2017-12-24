const Token = artifacts.require('./HelloWorldToken.sol')

contract('Token', async function (accounts) {
  it ('should put all TotalSupply in the first account', async function () {
    const token = await Token.deployed()
    var firstAccountBalance = await token.balanceOf.call(accounts[0])
    var totalSupply = await token.totalSupply.call(accounts[0])
    return assert.equal(firstAccountBalance.toNumber(), totalSupply.toNumber(), 'totalSupply wasn\'t in the first account')
  })
  it ('should transfer token correctly', async function () {
    const token = await Token.deployed()
    // Get initial balances of first and second account.
    var accountOne = accounts[0]
    var accountTwo = accounts[1]

    if (!accountOne) assert.fail('accountOne not existed')
    if (!accountTwo) assert.fail('accountTwo not existed')

    var amount = 100000

    var accountOneStartingBalance = await token.balanceOf.call(accountOne)
    var accountTwoStartingBalance = await token.balanceOf.call(accountTwo)

    await token.transfer(accountTwo, amount, {from: accountOne})

    var accountOneEndingBalance = await token.balanceOf.call(accountOne)
    var accountTwoEndingBalance = await token.balanceOf.call(accountTwo)

    assert.equal(
      accountOneEndingBalance.toNumber(),
      accountOneStartingBalance.toNumber() - amount,
      'Amount wasn\'t correctly taken from the sender'
    )
    assert.equal(
      accountTwoEndingBalance.toNumber(),
      accountTwoStartingBalance.toNumber() + amount,
      'Amount wasn\'t correctly sent to the receiver'
    )
  })
  it ('should freeze the targeted account', async function () {
    const token = await Token.deployed()
    // Get initial balances of first and second account.
    var accountOne = accounts[0]
    var accountTwo = accounts[1]

    var amount = 100000

    var accountOneStartingBalance = await token.balanceOf.call(accountOne)
    var accountTwoStartingBalance = await token.balanceOf.call(accountTwo)

    // Test freezing
    await token.freezeAccount(accountOne, true, {from: accountOne})
    var isFrozen = await token.isFrozen.call(accountOne)
    assert.equal(isFrozen, true, 'freeze unsuccessful')

    await token.transfer(accountTwo, amount, {from: accountOne})

    var accountOneEndingBalance = await token.balanceOf.call(accountOne)
    var accountTwoEndingBalance = await token.balanceOf.call(accountTwo)

    assert.equal(accountOneEndingBalance.toNumber(), accountOneStartingBalance.toNumber(), 'still be able to transfer after freezed')
    assert.equal(accountTwoEndingBalance.toNumber(), accountTwoStartingBalance.toNumber(), 'still be able to transfer after freezed')

    // Test unfreezing
    await token.freezeAccount(accountOne, false, {from: accountOne})
    isFrozen = await token.isFrozen.call(accountOne)
    assert.equal(isFrozen, false, 'unfreeze unsuccessful')

    await token.transfer(accountTwo, amount, {from: accountOne})

    accountOneEndingBalance = await token.balanceOf.call(accountOne)
    accountTwoEndingBalance = await token.balanceOf.call(accountTwo)

    assert.equal(
      accountOneEndingBalance.toNumber(),
      accountOneStartingBalance.toNumber() - amount,
      'still not able to transfer after unfreezed'
    )
    assert.equal(
      accountTwoEndingBalance.toNumber(),
      accountTwoStartingBalance.toNumber() + amount,
      'still not able to transfer after unfreezed'
    )
  })
})
