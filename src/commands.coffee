Commands =
  toggle:
    invoke: (event) ->
      Safarikai.toggle()
      event.target.validate()
    validate: (event) ->
      event.target.toolTip  = if Safarikai.enabled then "Disable Safarikai" else "Enable Safarikai"
      event.target.image    = safari.extension.baseURI + (if Safarikai.enabled then "IconEnabled.png" else "IconDisabled.png")
