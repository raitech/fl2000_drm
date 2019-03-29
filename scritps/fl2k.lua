-- Copyright 2019 Artem Mygaiev <joculator@gmail.com>

fl2k_proto = Proto("fl2k", "FL2000 Protocol")

local f_stage = Field.new("usb.control_stage")
local stage_types = {
    SETUP = 0,
    DATA = 1,
    STATUS = 2,
}
local op_types = {
    [0x40] = "Read",
    [0x41] = "Write",
}
local f = fl2k_proto.fields
f.f_reg_op = ProtoField.uint8("fl2k.reg_op", "Register operation", base.HEX, op_types)
f.f_reg_addr = ProtoField.uint16("fl2k.reg_addr", "Register address", base.HEX)
f.f_reg_value = ProtoField.uint32("fl2k.reg_value", "Register value", base.HEX)

function fl2k_proto.dissector(buffer, pinfo, tree)
    local stage = f_stage()
    local t_fl2k = tree:add(fl2k_proto, buffer())

    pinfo.cols["info"]:set("FL2000 Registers")

    if (stage.value == stage_types.SETUP) then
        -- For future use
        local reg_op = buffer(0, 1):uint()
        local reg_addr = buffer(3, 2):le_uint()

        t_fl2k:add(f.f_reg_op, buffer(0, 1))
        t_fl2k:add_le(f.f_reg_addr, buffer(3, 2))
        
    elseif (stage.value == stage_types.DATA) then
        -- For future use
        local reg_value = buffer(0, 4):le_uint()

        t_fl2k:add_le(f.f_reg_value, buffer(0, 4))

    elseif (stage == stage_types.STATUS) then
        -- Do nothing
    end
    
end

usb_table = DissectorTable.get("usb.control")
usb_table:add(0xffff, fl2k_proto)