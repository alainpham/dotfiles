rule = {
  matches = {
    {
      { "node.name", "equals", "alsa_output.pci-0000_00_1f.3.analog-stereo" },
    },
  },
  apply_properties = {
    ["priority.session"] = 2000,
  },
}
table.insert(alsa_monitor.rules, rule)