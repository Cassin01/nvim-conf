local style = require("wf.config.style").new()

-- Default configuration
local _opts = {
  prompt = "> ",
  selector = "which",
  text_insert_in_advance = "",
  key_group_dict = {},
  prefix_size = 7,
  output_obj_which_mode_desc_format = function(match_obj)
    local desc = match_obj.text
    local front = desc:match("^%[[%l%u%d%si%-]+%]")
    if front == nil then
      if match_obj.type == "group" then
        return { { match_obj.text, "WFWhichDesc" }, { " *", "WFExpandable" } }
      else
        return { { match_obj.text, "WFWhichDesc" } }
      end
    end
    local back = desc:sub(#front + 1)
    if match_obj.type == "group" then
      return { { front, "WFGroup" }, { back, "WFWhichDesc" }, { " *", "WFExpandable" } }
    else
      return { { front, "WFGroup" }, { back, "WFWhichDesc" } }
    end
  end,
  style = style,
}


return _opts
