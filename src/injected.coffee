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
      left -= overflowX if overflowX > 0
      popup.style.left = left + "px"

      top = clientY + scrollY + margin
      top = clientY + scrollY - popup.offsetHeight - margin if clientY > window.innerHeight / 2
      popup.style.top = top + "px"

  messageEventHandler = (e) ->
    messageName = e.name
    messageData = e.message

    switch messageName
      when "showResult" then showResult messageData.word, messageData.result

  safari.self.addEventListener "message", messageEventHandler, false
)(document, window)
