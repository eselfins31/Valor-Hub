local State = {}
State.settings = {
  clickTp = false,
  speedEnabled = false,
  walkSpeed = 100,
  -- Keybinds
  bindClickTpToggle = "T",
  bindAutoCollectToggle = "G",
  bindAutoSellToggle = "H",
  bindSpeedToggle = "Z",
}
function State.update(partial) for k,v in pairs(partial) do State.settings[k]=v end end
function State.get(key) return State.settings[key] end
return State
