((doc, window) ->
  clientX = 0
  clientY = 0
  popupTagId = "safarikai-popup"
  mouseEventHandler = (e) ->
    clientX = e.clientX
    clientY = e.clientY
    range = doc.caretRangeFromPoint e.clientX, e.clientY
    if range
      range.expand "word"
      sel = doc.defaultView.getSelection()
      word = range.toString().trim()
      safari.self.tab.dispatchMessage "lookupWord", word
      #sel.removeAllRanges()
      #sel.addRange range

  doc.onmousemove = doc.onmouseover = doc.onmouseout = mouseEventHandler

  getPopup = ->
    doc.getElementById popupTagId

  injectPopup = ->
    return if getPopup()

    popup = doc.createElement "div"
    popup.id = "safarikai-popup"
    doc.body.appendChild popup

  hidePopup = ->
    getPopup().style.display = "none"

  showResult = (word, result) ->
    injectPopup()
    popup = getPopup()
    popup.style.display = "block"
    popup.innerHTML     = result
    if result is ""
      hidePopup()
    else
      margin = 30

      left = clientX + scrollX
      overflowX = clientX + popup.offsetWidth - window.innerWidth + margin
      if overflowX > 0
        left -= overflowX
      popup.style.left = left + "px"

      top = clientY + scrollY
      overflowY = clientY + popup.offsetHeight - window.innerHeight + margin * 2
      if overflowY > 0
        top -= overflowY
      popup.style.top = top + margin + "px"

  messageEventHandler = (e) ->
    messageName = e.name
    messageData = e.message

    switch messageName
      when "showResult" then showResult messageData.word, messageData.result

  safari.self.addEventListener "message", messageEventHandler, false
)(document, window)
