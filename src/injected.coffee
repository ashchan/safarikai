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
        @clientX = e.clientX
        @clientY = e.clientY
        @createRange e.clientX, e.clientY
        safari.self.tab.dispatchMessage "lookupWord", word: @selectionText, url: @window.location.href if @selectionText?.length > 0
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

  createRange: (x, y) ->
    ele = @doc.elementFromPoint(x, y)
    @range = null
    if ele.tagName in @_ignoreElements
      @selectionText = ""
    else if ele.tagName is "IMG"
      @selectionText = ele.alt.trim()
    else
      range = @doc.caretRangeFromPoint x, y
      container = range.startContainer
      offset = range.startOffset
      if range
        range.setStart container, offset
        range.setEnd container, Math.min(container.data?.length, offset + 10)
        text = range.toString()
        if text.length > 0 and text isnt @selectionText
          @range = range
          @rangeOffset = offset
          @selectionText = text

  highlight: (word) ->
    return unless @highlightText and @range
    return if @mouseDown
    sel = @doc.defaultView.getSelection()
    return if not @highlighted and sel.toString().length > 0
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
    translation = row.translation.replace /;/g, "; "
    """
    <li>
      <div class='kana'>#{ row.kana }</div>
      <div class='romaji'>#{ row.romaji }</div>
      <div class='kanji'>#{ kanji }</div>
      <div class='translation'>#{ translation }</div>
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

  _ignoreElements:
    ["TEXTAREA", "INPUT"]

client = new Client document, window
