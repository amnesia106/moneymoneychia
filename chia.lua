-- Chia Extension for MoneyMoney
-- Fetches balances from xchscan api
--
-- Copyright (c) 2021 amnesia106
--  xch1hyqsupkrpanpua355fg7hkq3aufzhyrulv3empkq3w9cl3ltptdsaac45u - CHIA
-- S-A4PZ-XVX8-RN9N-76HPE - SIGNA
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking{
  version = 0.1,
  description = "Include your Chia as cryptoportfolio in MoneyMoney by providing chia wallet addresses as usernme (comma seperated)",
  services= { "Chia" }
}

local chiaAddress
local connection = Connection()
local currency = "EUR"

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Chia"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  chiaAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Chia",
    accountNumber = "Chia",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestchiaPrice()

  for address in string.gmatch(chiaAddress, '([^,]+)') do
    chiaQuantity = requestChiaQuantityForchiaAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = chiaQuantity,
      price = prices,
    }
  end

  return {securities = s}
end

function EndSession ()
end

function requestchiaPrice()
  response = connection:request("GET", crypocompareRequestUrl(), {})
  json = JSON(response)
  return json:dictionary()['EUR']
end


function requestChiaQuantityForchiaAddress(chiaAddress)
  response = connection:request("GET", ChiaRequestUrl(chiaAddress), {})
  json = JSON(response)
  XCH = json:dictionary()['xch']
  return XCH
end

function crypocompareRequestUrl()
  return "https://min-api.cryptocompare.com/data/price?fsym=XCH&tsyms=EUR"
end

function ChiaRequestUrl(chiaAddress)
  return "https://xchscan.com/api/account/balance?address=" .. chiaAddress
end

-- SIGNATURE: MCwCFF21SQIbGAGlkBuDn+rzsQYOCwY4AhRnghZjHLWhI7+jDbvmmG9M3C/kyg==
