
MENU = {}

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        MENU.CloseAll()
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('menuapi:getData', function (menu)
        MENU = menu
    end)
end)

function AskNumberValue()
    local value = nil
    local error = false

    local myInput = {
        type = "enableinput", -- don't touch
        inputType = "input", -- input type
        button = "Confirm", -- button name
        placeholder = "somme", -- placeholder name
        style = "block", -- don't touch
        attributes = {
            inputHeader = "Argent", -- header
            type = "number", -- inputype text, number,date,textarea
            pattern = "[0-9.]{1,10}", --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
            title = "numbers only", -- if input doesnt match show this message
            style = "border-radius: 10px; background-color: ; border:none;" -- style
        }
    }

    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(cb)
        local result = tonumber(cb)
        if result ~= "" and result then
            value = result
        else
            TriggerEvent("vorp:TipBottom", "Invalid", 6000)
            error = true
        end
    end)

    while value == nil and not error do
        Wait(100)
    end

    return error, tonumber(value)
end

function OpenWallet(money)
    local elements = {
        { label = string.format("Argent: %d$", money), desc = "Argent dans le portefeuille" },
        { label = "Déposer", value = 'deposit', desc = "Déposer de l'argent" },
        { label = "Retirer", value = 'withdraw', desc = "Prendre l'argent" },
        { label = "Close", value = 'close', desc = "Close" }
    }

    MENU.Open('default',
    GetCurrentResourceName(),
    "portefeuille",
    {
        title    = "Portefeuille",
        subtext  = "Les petits sous",
        align    = 'top-left',
        elements = elements,
    },
    function(data, menu)
        if data.current.value == 'deposit' then
            local err, amount = AskNumberValue()

            if err then
                return
            end

            if amount then
                TriggerServerEvent('nolosha_wallet:deposit', tonumber(amount))
            end
        elseif data.current.value == 'withdraw' then
            local err, amount = AskNumberValue()

            if err then
                return
            end

            -- TODO: check if withdraw amount is inferior to wallet amount
            if amount > money then
                TriggerEvent("vorp:TipBottom", "Il n'y a pas assez d'argent dans le portefeuille", 5000)
                return
            end

            if amount then
                TriggerServerEvent('nolosha_wallet:withdraw', amount)
            end
        elseif data.current.value == 'close' then
            CloseWallet()
        end
    end, function(data, menu)
        CloseWallet()
    end)
end

function CloseWallet()
    MENU.CloseAll()
    TriggerServerEvent('nolosha_wallet:close_wallet')
end

RegisterNetEvent('nolosha_wallet:open')
AddEventHandler('nolosha_wallet:open', function(money)
    OpenWallet(money)
end)

RegisterNetEvent('nolosha_wallet:refresh')
AddEventHandler('nolosha_wallet:refresh', function(money)
    MENU.CloseAll()
    OpenWallet(money)
end)