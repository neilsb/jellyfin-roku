sub init()

  m.markupgrid = m.top.findNode("exampleMarkupGrid")
  m.backdrop = m.top.findNode("backdrop")
  m.backdropT = m.top.findNode("backdropTransition")

  m.swapAnimation = m.top.findNode("testAnimation")
  m.swapAnimation.observeField("state", "swapDone")
  

  m.top.setFocus(true)
  m.data = CreateObject("roSGNode", "ContentNode")

  m.loadedRows = 0

  m.spinner = CreateObject("roSGNode", "BusySpinner")
  m.spinner.uri="pkg:/images/busyspinner_hd.png"
  m.spinner.visible = true

  m.data.appendChild(m.spinner)
  m.markupgrid.content = m.data

  m.backdropT.observeField("loadStatus", "newBGLoaded")

  m.bgToLoad = ""

  'updateSize()
end sub

sub updateSize()
  m.markupgrid.numRows = 5
  if m.markupgrid.numColumns = invalid or m.markupgrid.numColumns = 0 then
    m.markupgrid.numColumns = 6
  end if

  dimensions = m.top.getScene().currentDesignResolution

  border = 75
  topSpace = border + 105
'  m.markupgrid.translation = [border, topSpace]

  spaceBetween = 20

  itemWidth = (1726 - ((m.markupgrid.numColumns - 1) * spaceBetween)) / m.markupgrid.numColumns



  ' 1726


  textHeight = 100
  'itemWidth = (dimensions["width"] - border*2) / m.markupgrid.numColumns -20
  itemHeight = itemWidth * 1.5 + textHeight

'  if itemHeight*m.markupgrid.numRows > (dimensions["height"] - border - 115) then
'    ratio = (itemHeight*m.markupgrid.numRows) / (981 - topSpace - 15)
'    itemHeight = itemHeight / ratio
'    itemWidth = itemWidth / ratio
'  end if
'  m.top.visible = true

  ' Size of the individual rows
'  m.top.itemSize = [dimensions["width"] - border*2, itemHeight]
  ' Spacing between Rows
'  m.top.itemSpacing = [ 0, 10]

  ' Size of items in the row
  m.markupgrid.itemSize = [ itemWidth, itemHeight ]
  ' Spacing between items in the row
  itemSpace = 20 ' (dimensions["width"] - border*2 - itemWidth*m.markupgrid.numColumns) / (m.markupgrid.numColumns-1)
  m.markupgrid.itemSpacing = [ itemSpace-1, 0 ]
end sub





sub LibrarySet() 

  loadLatest = createObject("roSGNode", "LoadItemsTask2")
  loadLatest.itemId = m.top.itemId

'  metadata = { "title" : lib.name }
'  metadata.Append({ "contentType" : lib.json.CollectionType })
'  loadLatest.metadata = metadata

  loadLatest.observeField("content", "ItemDataLoaded")
  loadLatest.control = "RUN"


end sub


sub ItemDataLoaded(msg)

  itemData = msg.GetData()

  data = msg.getField()
  node = msg.getRoSGNode()
  node.unobserveField("content")

  if itemData = invalid then return 

  for each item in itemData
    m.data.appendChild(item)
  end for


  m.markupgrid.content = m.data

  m.loadedRows = m.markupgrid.content.getChildCount() / m.markupgrid.numColumns

  m.markupgrid.setFocus(true)

  m.markupgrid.observeField("itemFocused", "onItemFocused")

end sub




sub onItemFocused()

  moo = CInt(m.markupgrid.itemFocused / m.markupgrid.numColumns) + 1
 ' print "New Focus Item - Row "  moo

  ' Set Background
  itemInt = m.markupgrid.itemFocused
  child = m.markupgrid.content.getChild(m.markupgrid.itemFocused)

  if itemInt = 0 return


'  print "Item Number " itemInt

  print "New item focused - Current Animation Status: " m.swapAnimation.state

  if m.swapAnimation.state = "stopped" then
    
    if m.backdropT.loadStatus = "ready" then
      print "Swapping images"
      m.backdrop.uri = m.backdropT.uri
      m.backdrop.opacity = 0.25
      m.backdropT.opacity = 0
    end if
    print "Setting new image"
    m.backdropt.uri = m.markupgrid.content.getChild(m.markupgrid.itemFocused).backdropUrl

  else
    m.bgToLoad = m.markupgrid.content.getChild(m.markupgrid.itemFocused).backdropUrl
    print "!!!! Think this is the problem...."
  end if



  if moo >= m.loadedRows - 3 then
    loadMoreData()
  end if

end sub 

sub newBGLoaded()

  Print "Updated Load Status: " m.backdropT.loadStatus

  if m.backdropT.loadStatus = "ready"
    print "Starting Swap"
    m.swapAnimation.control = "start"
  end if


end sub

sub swapDone()

  if m.swapAnimation.state = "stopped" and m.backdropT.uri <> m.bgToLoad and m.bgToLoad <> ""  then

    print "Swapping to latest"
   
    m.backdrop.uri = m.backdropT.uri
    m.backdrop.opacity = 0.25
    m.backdropT.opacity = 0
    m.backdropt.uri = m.bgToLoad
    m.bgToLoad = ""

  end if

end sub


sub loadMoreData()

  if m.Loading = true then
    print "------ ALREADY LOADING!!!"
    return
  end if

  m.Loading = true

  print "Loading from start index: " m.markupgrid.content.getChildCount()

  loadMore = createObject("roSGNode", "LoadItemsTask2")
  loadMore.itemId = m.top.itemId
  loadMore.startIndex = m.markupgrid.content.getChildCount()
  loadMore.itemType = "Movie"

'  metadata = { "title" : lib.name }
'  metadata.Append({ "contentType" : lib.json.CollectionType })
'  loadLatest.metadata = metadata

  loadMore.observeField("content", "moreDataLoaded")
  loadMore.control = "RUN"


end sub



sub moreDataLoaded(msg)
  
  print "More Data Loaded"

  itemData = msg.GetData()

  data = msg.getField()
  node = msg.getRoSGNode()
  node.unobserveField("content")


  if itemData = invalid then 
    m.Loading = false
    return 
  end if

  for each item in itemData
    m.data.appendChild(item)
  end for


'  m.markupgrid.content = m.data

  m.loadedRows = m.markupgrid.content.getChildCount() / m.markupgrid.numColumns

 ' m.markupgrid.setFocus(true)

  'm.markupgrid.observeField("itemFocused", "onItemFocused")

  print "New Total Items " m.markupgrid.content.getChildCount()
  print "New toral rows " m.loadedRows

    m.Loading = false

end sub


sub setBackground()
  print "Setting Background!!!!!!!!!!!!!!!!!" m.top.bgUrl
end sub


sub SetupRows()


  ' for each item in m.top.objects.Items
  '     moo = CreateObject("roSGNode", "ContentNode")
  '     moo.title = item.title
  '     m.data.appendChild(moo)
  ' end for

  ' m.markupgrid.content = m.data

end sub