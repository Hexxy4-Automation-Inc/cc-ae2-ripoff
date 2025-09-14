local pretty = require "cc.pretty"

os.setComputerLabel("Yennefer")


local data = {
    config = {
        dumpId = nil,
        requesterId = nil,
        craftingStations = nil
    },
    items = {
        -- ["minecraft:oak_planks"] = {
        --     {
        --         storageId = "minecraft:chest_1",
        --         slot = 1,
        --         amount = 64,
        --     },
        --     {
        --         storageId = "minecraft:chest_3",
        --         slot = 5,
        --         amount = 20,
        --     },
        -- },
    },
    storage = {
        -- ["minecraft:chest_1"] = {
        --     [1] = false,
        --     [2] = false,
        -- }
    },
    metatables = {
        item = {
            __eq = function(i1, i2)
                return i1.amount == i2.amount
            end,
            __lt = function(i1, i2)
                return i1.amount < i2.amount
            end,
            __le = function(i1, i2)
                return i1.amount <= i2.amount
            end
        },
    },
    inventory = {}
}

function data:addItem(itemName, storageId, slot, amount)
    if not self.items[itemName] then
        self.items[itemName] = {
            totalAmount = 0
        }
    end
    self.items[itemName].totalAmount = self.items[itemName].totalAmount + amount
    table.insert(self.items[itemName], {
        storageId = storageId,
        slot = slot,
        amount = amount,
        __eq = data.metatables.item.__eq,
        __lt = data.metatables.item.__lt,
        __le = data.metatables.item.__le,
    })
    self.storage[storageId][slot] = itemName
end

function data:insertItem()

end

function data:removeItem(itemName, targetId, slot, amount)

end

-- read config
local configFile = fs.open("/.config/ae2.json", "r")
local configFileContent = textutils.unserialiseJSON(configFile.readAll())
configFile.close()
data.config = {
    dumpId = configFileContent.dumpId,
    requesterId = configFileContent.requesterId,
    craftingStations = configFileContent.craftingStations,
}

data.inventory = table.pack(peripheral.find("inventory"))

function data:scanAllStorages()
    self.storage = {}
    self.items = {}

    for _, storage in ipairs(self.inventory) do
        local storageName = peripheral.getName(storage)
        local items = storage.list()

        self.storage[storageName] = {}
        for i = 1, storage.size(), 1 do
            self.storage[storageName][i] = false
        end

        for slot, item in pairs(items) do
            self:addItem(item.name, storageName, slot, item.count)
        end
    end
end

data:scanAllStorages()
print(pretty.pretty_print(data.items))

local free, used = 0, 0
for _, inv in pairs(data.storage) do
    for index, slot in ipairs(inv) do
        if slot then
            used = used + 1
        else
            free = free + 1
        end
    end
end

print("used", used, "free", free)