sub init()

  m.itemGrid = m.top.findNode("itemGrid")
  m.backdrop = m.top.findNode("backdrop")
  m.backdropT = m.top.findNode("backdropTransition")

  m.swapAnimation = m.top.findNode("testAnimation")
  m.swapAnimation.observeField("state", "swapDone")
  

  m.top.setFocus(true)
  m.data = CreateObject("roSGNode", "ContentNode")

  m.loadedRows = 0
  m.loadedItems = 0

  m.spinner = CreateObject("roSGNode", "BusySpinner")
  m.spinner.uri="pkg:/images/busyspinner_hd.png"
  m.spinner.visible = true

  m.data.appendChild(m.spinner)
  m.itemGrid.content = m.data
  m.itemGrid.setFocus(true)
  m.itemGrid.observeField("itemFocused", "onItemFocused")


  m.backdropT.observeField("loadStatus", "newBGLoaded")

  m.bgToLoad = ""


  m.loadItemsTask = createObject("roSGNode", "LoadItemsTask2")
  
end sub




'
'Load initial set of Data
sub loadInitialItems() 
  m.loadItemsTask.itemId = m.top.itemId
  m.loadItemsTask.observeField("content", "ItemDataLoaded")
  m.loadItemsTask.itemType = "Movie"
  m.loadItemsTask.control = "RUN"
end sub

'
'Handle loaded data, and add to Grid
sub ItemDataLoaded(msg)
 
  itemData = msg.GetData()
  data = msg.getField()

  if itemData = invalid then 
    m.Loading = false
    return 
  end if

  for each item in itemData
    m.data.appendChild(item)
  end for

  'Update the stored counts
  m.loadedItems = m.itemGrid.content.getChildCount() 
  m.loadedRows = m.loadedItems / m.itemGrid.numColumns
  m.Loading = false
end sub



sub onItemFocused()

  focusedRow = CInt(m.itemGrid.itemFocused / m.itemGrid.numColumns) + 1

  ' Set Background
  itemInt = m.itemGrid.itemFocused
  child = m.itemGrid.content.getChild(m.itemGrid.itemFocused)

  if itemInt = 0 return



  if m.swapAnimation.state = "stopped" then
    
    if m.backdropT.loadStatus = "ready" then
      m.backdrop.uri = m.backdropT.uri
      m.backdrop.opacity = 0.25
      m.backdropT.opacity = 0
    end if
    m.backdropt.uri = m.itemGrid.content.getChild(m.itemGrid.itemFocused).backdropUrl

  else
    m.bgToLoad = m.itemGrid.content.getChild(m.itemGrid.itemFocused).backdropUrl
  end if

  ' Load more data if focus is within last 3 rows, and there are more items to load
  if focusedRow >= m.loadedRows - 3 and m.loadeditems < m.loadItemsTask.totalRecordCount then
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

'
'Load next set of items
sub loadMoreData()

  if m.Loading = true then return

  m.Loading = true
  m.loadItemsTask.startIndex = m.loadedItems
  m.loadItemsTask.control = "RUN"
end sub