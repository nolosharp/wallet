UsedWalletRegistry = {}

exports.vorp_inventory:registerUsableItem(Config.itemName, function(data)
    local _source = data.source
    local item = data.item

    local User = exports.vorp_core:GetCore().getUser(_source)
    local Character = User.getUsedCharacter
    --local characterMoney = Character.money

    UsedWalletRegistry[_source] = item

    local walletMoney = item.metadata and item.metadata.money or 0

    TriggerClientEvent('nolosha_wallet:open', _source, walletMoney)
    exports.vorp_inventory:closeInventory(_source)
end)

local function buildWalletMetadata(amount)
    return {
        description = string.format("<b>Argent</b>: %d$", amount),
        money = amount
    }
end

local function refreshItem(player, itemId)
    local item = exports.vorp_inventory:getItemByMainId(player, itemId)
    if not item then
        print('Failed to get item')
        return
    end

    UsedWalletRegistry[player] = item
end

RegisterServerEvent("nolosha_wallet:close_wallet")
AddEventHandler("nolosha_wallet:close_wallet", function()
    local _source = source

    UsedWalletRegistry[_source] = nil
end)

RegisterServerEvent("nolosha_wallet:deposit")
AddEventHandler("nolosha_wallet:deposit", function(amount)
    local _source = source

    local User = exports.vorp_core:GetCore().getUser(_source)
    local Character = User.getUsedCharacter
    local characterMoney = Character.money

    if amount >= characterMoney then
        TriggerClientEvent('vorp:TipRight', _source, "Vous n'avez pas assez d'argent", 3000)
        return
    end

    local item = UsedWalletRegistry[_source]
    if not item then
        TriggerClientEvent('vorp:TipRight', _source, 'Pas de porte monnaie ouvert', 3000)
        return
    end

    local walletMoney = item.metadata and item.metadata.money or 0
    local newAmount = walletMoney + amount

    Character.removeCurrency(0, amount)
    TriggerClientEvent('vorp:TipRight', _source, 'Vous avez déposé ' .. amount .. ' $', 3000)


    local ok = exports.vorp_inventory:setItemMetadata(_source, item.mainid, buildWalletMetadata(newAmount), 1)
    if not ok then
        print('Failed to set wallet metadata')
    end

    TriggerClientEvent('nolosha_wallet:refresh', _source, newAmount)
    refreshItem(_source, item.mainid)
end)

RegisterServerEvent("nolosha_wallet:withdraw")
AddEventHandler("nolosha_wallet:withdraw", function(amount)
    local _source = source

    local User = exports.vorp_core:GetCore().getUser(_source)
    local Character = User.getUsedCharacter

    Character.addCurrency(0, amount)
    TriggerClientEvent('vorp:TipRight', _source, 'Vous avez retiré ' .. amount .. ' $', 3000)

    local item = UsedWalletRegistry[_source]
    if not item then
        TriggerClientEvent('vorp:TipRight', _source, 'Pas de porte monnaie ouvert', 3000)
        return
    end

    local walletMoney = item.metadata and item.metadata.money or 0
    local newAmount = walletMoney - amount

    local ok = exports.vorp_inventory:setItemMetadata(_source, item.mainid, buildWalletMetadata(newAmount), 1)
    if not ok then
        print('Failed to set wallet metadata')
    end

    TriggerClientEvent('nolosha_wallet:refresh', _source, newAmount)
    refreshItem(_source, item.mainid)
end)