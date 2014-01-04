class Client
  constructor: (@doc, @window) ->
    @clientX       = 0
    @clientY       = 0
    @popupTagId    = "safarikai-popup"
    @enabled       = true
    @mouseDown     = false
    @highlighted   = false
    @highlightText = true
    @rangeOffset   = 0

    @doc.onmousemove = (e) =>
      unless @enabled and not @mouseDown
        @hidePopup()
      else
        @createRange e
        if @selectionText?.length > 0
          safari.self.tab.dispatchMessage "lookupWord", word: @selectionText, url: @window.location.href
        else
          @clearHighlight()
          @hidePopup()
      true

    @doc.onmouseout  = (e) => @hidePopup()
    @doc.onmousedown = (e) =>
      if e.button is 0
        @mouseDown = true
        @clearHighlight()
      true
    @doc.onmouseup   = (e) =>
      if e.button is 0
        @mouseDown = false
      true

    safari.self.addEventListener "message", (e) =>
      messageData = e.message

      switch e.name
        when "showResult" then @showResult messageData.word, messageData.url, messageData.result
        when "status" then @updateStatus messageData

    # Ask status on load
    safari.self.tab.dispatchMessage "queryStatus"

  createRange: (e) ->
    @clientX = e.clientX
    @clientY = e.clientY
    ele = @doc.elementFromPoint(@clientX, @clientY)
    @range = null
    if ele.tagName in @_ignoreElements
      @selectionText = ""
    else if ele.tagName is "IMG"
      @selectionText = ele.alt.trim()
    else
      range = @doc.caretRangeFromPoint @clientX, @clientY
      container = range.startContainer
      offset = range.startOffset

      if offset is container.data?.length
        if @_isInlineNode(e.target) and container.parentNode.innerText isnt e.target.innerText
          container = e.target.firstChild
          offset = 0

      range.setStart container, offset
      range.setEnd container, Math.min(container.data?.length, offset + 12)

      text = range.toString()
      if text isnt @selectionText
        @range = range
        @rangeOffset = offset
        @selectionText = text

  highlight: (word) ->
    return unless @highlightText and @range
    return if @mouseDown
    sel = @doc.defaultView.getSelection()
    return if not @highlighted and sel.toString().length > 0 # user selection
    sel.removeAllRanges()
    if @range
      container = @range.startContainer
      @range.setEnd container, Math.min(container.data?.length, @rangeOffset + word.length)
      sel.addRange @range
    @highlighted = true

  clearHighlight: ->
    return unless @highlightText
    if @highlighted
      sel = @doc.defaultView.getSelection()
      sel.removeAllRanges()
      @highlighted = false

  getPopup: -> @doc.getElementById @popupTagId

  injectPopup: ->
    return if @getPopup()

    popup = @doc.createElement "div"
    popup.id = "safarikai-popup"
    @doc.body.appendChild popup

  hidePopup: -> @getPopup()?.style.display = "none"

  decorateRow: (row) ->
    kanji = if row.kanji.length isnt 0 then row.kanji else row.kana
    """
    <li>
      <div class='kana'>#{ row.kana }</div>
      <div class='romaji'>#{ row.romaji }</div>
      <div class='kanji'>#{ kanji }</div>
      <div class='translation'>#{ row.translation }</div>
    </li>
    """

  showResult: (word, url, result) ->
    return if @window.location.href isnt url

    @injectPopup()
    popup = @getPopup()
    popup.style.display = "block"
    if result.length is 0
      @clearHighlight()
      @hidePopup()
    else
      @highlight(word)
      htmlRows = (@decorateRow row for row in result)
      popup.innerHTML = "<ul>#{ htmlRows.join '' }</ul>"

      margin = 30

      left = @clientX + @window.scrollX
      overflowX = @clientX + popup.offsetWidth - @window.innerWidth + margin
      left -= overflowX if overflowX > 0
      popup.style.left = left + "px"

      top = @clientY + @window.scrollY + margin
      top = @clientY + @window.scrollY - popup.offsetHeight - margin if @clientY > @window.innerHeight / 2
      popup.style.top = top + "px"

  updateStatus: (status) ->
    @enabled       = status.enabled
    @highlightText = status.highlightText
    @hidePopup() unless @enabled

  _isInlineNode: (node) ->
    return true if node.nodeName is "#text"
    display = @doc.defaultView.getComputedStyle(node, null).getPropertyValue "display"
    display is "inline" or display is "inline-block"

  _ignoreElements:
    ["TEXTAREA", "INPUT"]

client = new Client document, window
