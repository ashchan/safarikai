class Client
  constructor: (@doc, @window) ->
    @clientX         = 0
    @clientY         = 0
    @popupTagId      = "safarikai-popup"
    @enabled         = true
    @mouseDown       = false
    @highlighted     = false
    @highlightText   = true
    @showRomaji      = true
    @showTranslation = true
    @rangeOffset   = 0

    @doc.onmousemove = (e) =>
      unless @enabled and not @mouseDown
        @hidePopup()
      else
        @createRange e
        if @selectionText?.length > 0
          safari.extension.dispatchMessage "lookupWord", word: @selectionText, url: @window.location.href
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
    safari.extension.dispatchMessage "queryStatus"

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
    kanji = if row.kanji isnt row.kana then row.kanji else ""
    """
    <li>
      <div class='kana'>#{ row.kana }</div>
      #{ if kanji.length > 0 then "<div class='kanji'>" + kanji + "</div>" else "" }
      #{ if @showRomaji or @showTranslation then "<div class='translation'>" else "" }
        #{ if @showRomaji then "<div class='romaji'>[" + row.romaji + "]</div>" else "" }
        #{ if @showTranslation then "#{row.translation}" else "" }
      #{ if @showRomaji or @showTranslation then "</div>" else "" }
    </li>
    """

  showResult: (word, url, result) ->
    console.log "---"
    console.log "Result for " + word
    console.log result
    return if @window.location.href isnt url

    @injectPopup()
    popup = @getPopup()
    popup.style.display = "block"
    if result.length is 0
      @clearHighlight()
      @hidePopup()
    else
      @highlight word
      htmlRows = (@decorateRow row for row in result)
      popup.innerHTML = "<ul class='results'>#{ htmlRows.join '' }</ul>"
      popup.style.maxWidth = if @window.innerWidth < 400 then "80%" else "500px"

      left = @clientX + @window.scrollX
      overflowX = @clientX + popup.offsetWidth - @window.innerWidth + 10
      left -= overflowX if overflowX > 0
      popup.style.left = left + "px"

      margin = 30
      top = @clientY + @window.scrollY + margin
      top = @clientY + @window.scrollY - popup.offsetHeight - margin if @clientY > @window.innerHeight / 2
      popup.style.top = top + "px"

  updateStatus: (status) ->
    @enabled         = status.enabled
    @highlightText   = status.highlightText
    @showRomaji      = status.showRomaji
    @showTranslation = status.showTranslation
    @hidePopup() unless @enabled

  _isInlineNode: (node) ->
    return true if node.nodeName is "#text"
    display = @doc.defaultView.getComputedStyle(node, null).getPropertyValue "display"
    display is "inline" or display is "inline-block"

  _ignoreElements:
    ["TEXTAREA", "INPUT"]

client = new Client document, window
