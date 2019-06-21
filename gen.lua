#!/usr/bin/env lua

-- generates ips patches from lgbtasm-formatted asm files.

local function fatal(err)
    io.stderr:write(tostring(err) .. '\n')
    os.exit(1)
end

if #arg < 2 then
    error(string.format('usage: lua %s <asmfile>... <outdir>', arg[0]))
end

local lgbtasm = require('lgbtasm/lgbtasm')
local struct = require('lua-struct/struct')
local outdir = arg[#arg]

local function writeips(filename, records)
    local file = io.open(filename, 'wb')
    file:write('PATCH')

    for _, record in ipairs(records) do
        -- address field is three bytes and not four, weirdly
        local data = lgbtasm.compile(table.concat(record.lines, '\n'))
        file:write(string.sub(struct.pack('>I', record.address), 2))
        file:write(struct.pack('>H', #data))
        file:write(data)
    end

    file:write('EOF')
    file:close()
end

for i = 1, #arg - 1 do
    local records, working_record = {}, nil

    for line in io.lines(arg[i]) do
        local address = string.match(line, '^_(%x+):')
        if address then
            -- address of new record found
            if working_record then
                table.insert(records, working_record)
            end
            working_record = {address = tonumber(address, 16), lines = {}}
        elseif working_record then
            -- otherwise add lines to existing record
            table.insert(working_record.lines, line)
        end
    end

    if working_record then
        table.insert(records, working_record)
    end

    writeips(string.gsub(arg[i], 'asm', 'ips'), records)
end
