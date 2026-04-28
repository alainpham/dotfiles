rule = {
  matches = {
    {
      { "device.name", "equals", "alsa_card.platform-snd_dummy.0" },
    },
  },
  apply_properties = {
    ["device.disabled"] = true,
  },
}
table.insert(alsa_monitor.rules,rule)

rule = {
  matches = {
    {
      { "device.name", "equals", "alsa_card.platform-snd_aloop.0" },
    },
  },
  apply_properties = {
    ["device.disabled"] = true,
  },
}
table.insert(alsa_monitor.rules,rule)
