#!/usr/bin/env lua

-- generates ips patches from lgbtasm-formatted asm files.

if #arg < 3 then
    error(string.format(
        'usage: lua %s <outfile> <bankfile> <asmfile>...', arg[0]))
end

local lgbtasm = require('lgbtasm/lgbtasm')
local struct = require('lua-struct/struct')
local outdir = arg[#arg]

-- returns the absolute position of bus bank:addr address
local function addroffset(bank, addr)
    if bank == 0 then
        return addr
    else
        return (bank - 1) * 0x4000 + addr
    end
end

-- creates an IPS file from the given asm blocks and defines
local function writeips(filename, blocks, defs)
    local file = io.open(filename, 'wb')
    file:write('PATCH')

    for _, block in ipairs(blocks) do
        -- address field is three bytes and not four, weirdly
        local data = lgbtasm.compile(
            table.concat(block.lines, '\n'), {defs = defs})
        if #data > 0 then
            local offset = addroffset(block.bank, block.addr)
            file:write(string.sub(struct.pack('>I', offset), 2))
            file:write(struct.pack('>H', #data))
            file:write(data)
        end
    end

    file:write('EOF')
    file:close()
end

-- returns a map of bank numbers of end-of-bank addresses, loaded from a file
local function loadbanks(path)
    local banks = {}

    for line in io.lines(path) do
        local bank = tonumber(string.match(line, '^%x+'), 16)
        local addr = tonumber(string.match(line, ',(%x+)'), 16)
        banks[bank] = addr
    end

    return banks
end

-- returns (bank, address, label)
local function parsemetalabel(ml)
    local tokens = {}
    for tok in string.gmatch(ml, '[^/]+') do
        table.insert(tokens, tok)
    end
    if string.match(ml, '/$') then
        table.insert(tokens, '')
    end

    if #tokens == 1 then
        return 0, 0, tokens[1]
    elseif #tokens == 2 then
        return tonumber(tokens[1], 16), 0, tokens[2]
    elseif #tokens == 3 then
        return tonumber(tokens[1], 16), tonumber(tokens[2], 16), tokens[3]
    else
        error('invalid metalabel: ' .. ml)
    end
end

-- give addresses to EOB (zero-value) asm blocks and make defines global
local function makedefs(blocks, banks)
    local defs = {}
    local floating = {}

    -- make placeholders defs for labels
    for _, block in ipairs(blocks) do
        if block.label ~= '' then
            defs[block.label] = 0
        end
        if block.addr == 0 then
            table.insert(floating, block)
        end
    end

    -- write asm using placeholders, to get compiled size
    for _, block in ipairs(floating) do
        block.addr = banks[block.bank]
        defs[block.label] = block.addr
        local data = lgbtasm.compile(
            table.concat(block.lines, '\n'), {defs = defs})
        banks[block.bank] = banks[block.bank] + #data

        -- error if a bank overflows
        if banks[block.bank] > 0x8000 or
            (block.bank == 0 and banks[block.bank] > 0x4000) then
            error(string.format('bank overflowed: %x', block.bank))
        end
    end

    return defs
end

-- loads asm blocks from a file
local function loadasmfile(blocks, path)
    local working_block = nil

    for line in io.lines(path) do
        local ml = string.match(line, '^(.+):$')

        if ml then
            -- address of new block found
            if working_block then
                table.insert(blocks, working_block)
            end
            local bank, addr, label = parsemetalabel(ml)
            working_block =
                {bank = bank, addr = addr, label = label, lines = {}}
        elseif working_block then
            -- otherwise add lines to existing block
            table.insert(working_block.lines, line)
        end
    end

    if working_block then
        table.insert(blocks, working_block)
    end

    return blocks
end

local function main()
    local banks = loadbanks(arg[2])
    local blocks = {}

    for i = 3, #arg do
        loadasmfile(blocks, arg[i])
    end

    local defs = makedefs(blocks, banks)
    writeips(arg[1], blocks, defs)
end

main()
