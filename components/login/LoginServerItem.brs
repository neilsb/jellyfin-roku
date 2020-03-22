  function itemContentChanged() 
    itemData = m.top.itemContent
    m.itemImage.uri = itemData.posterUrl
    m.itemText.text = itemData.labelText
    m.item2Text.text = itemData.label2Text
   
    m.itemText.font.size = "24"
    m.item2Text.font.size = "18"

    if itemData.label2Text = "" then
      m.itemText.translation = [60,10]
    end if

  end function
  
  function init() 
    m.itemImage = m.top.findNode("itemImage") 
    m.itemText = m.top.findNode("itemText") 
    m.item2Text = m.top.findNode("item2Text") 
  end function