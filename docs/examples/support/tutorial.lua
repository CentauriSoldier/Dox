-- Shared output conventions for executable tutorials. Every check asserts the
-- behavior it describes; expected errors are demonstrated separately.
local Tutorial = {}
function Tutorial.new(title, purpose)
    local D = {sections = 0, checks = 0, rejections = 0}
    local function format(value, depth)
        local kind = rawtype(value)
        if kind == "nil" then return "nil" end
        if kind == "string" then return string.format("%q", value) end
        if kind == "number" then return string.format("%.10g", value) end
        if kind == "boolean" then return tostring(value) end
        if type(value) == "null" then return "null" end
        if kind == "table" and type(value) == "table" then
            if (depth or 0) >= 2 then return "{...}" end
            local keys,parts = {},{}
            for key in pairs(value) do keys[#keys+1]=key end
            table.sort(keys,function(a,b) return tostring(a)<tostring(b) end)
            for _,key in ipairs(keys) do parts[#parts+1]=tostring(key).."="..format(value[key],(depth or 0)+1) end
            return "{"..table.concat(parts,", ").."}"
        end
        local ok,text=pcall(tostring,value)
        return ok and text or ("<"..type(value)..">")
    end
    D.format = format
    print("\n============================================================")
    print(title.." | executable tutorial")
    print(purpose)
    print("============================================================")
    function D.section(name, explanation)
        D.sections=D.sections+1
        print("\n["..D.sections.."] "..name)
        if explanation then print("WHY: "..explanation) end
    end
    function D.show(label,value)
        print(label.." => "..format(value).." ["..type(value).."]")
        return value
    end
    function D.note(text) print("NOTE: "..text) end
    function D.check(label,condition)
        assert(condition,"Tutorial check failed: "..label)
        D.checks=D.checks+1;print("[PASS] "..label)
    end
    function D.equal(label,actual,expected)
        local same=actual==expected
        if rawtype(actual)=="number" and rawtype(expected)=="number" then
            same=math.abs(actual-expected)<=1e-8*math.max(1,math.abs(expected))
        end
        D.check(label.." | actual="..format(actual)..", expected="..format(expected),same)
    end
    function D.reject(label,action)
        local ok,message=pcall(action)
        assert(not ok,"Expected a rejection: "..label)
        D.rejections=D.rejections+1;D.checks=D.checks+1
        print("[EXPECTED REJECTION] "..label)
        print("  REASON: "..tostring(message):match("[^\r\n]+"))
    end
    function D.observe(label,action)
        local ok,result=pcall(action)
        if ok then D.show(label,result) else print("[CURRENT LIMITATION] "..label..": "..tostring(result):match("[^\r\n]+")) end
        return ok,result
    end
    function D.input(name,default)
        local supplied=EXAMPLE_INPUT and EXAMPLE_INPUT[name]
        local value=supplied==nil and default or supplied
        D.show("INPUT "..name,value)
        return value
    end
    function D.list(text)
        local items={}
        for item in tostring(text):gmatch("[^,]+") do
            local clean=item:match("^%s*(.-)%s*$")
            if clean~="" then items[#items+1]=clean end
        end
        assert(#items<=20,"Use at most 20 comma-separated items")
        return items
    end
    function D.finish()
        print("\n[SUMMARY] "..title..": "..D.sections.." sections, "..D.checks.." verified checks, "..D.rejections.." expected rejections.")
        print("Edit example values and Run again. Expected rejections above demonstrate validation, not failed tests.")
    end
    return D
end
return Tutorial
