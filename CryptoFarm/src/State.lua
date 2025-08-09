local State = {}
State.settings = { clickTp = false }
function State.update(partial) for k,v in pairs(partial) do State.settings[k]=v end end
function State.get(key) return State.settings[key] end
return State
