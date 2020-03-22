  function itemContentChanged() 
    itemData = m.top.itemContent
    m.itemImage.uri = itemData.imageURL
    m.itemText.text = itemData.userName
   
    avatarBackgrounds = [ "#E1B222", "#4BB3DD", "#FF870F", "#4164A5",  "#008040", "#0094FF" ]

    ' If user has no image, assign color and default user image
    if itemData.imageURL.len() = 0 then
      if itemData.id = "-1" then
        m.itemImage.uri = "pkg:/images/key.png"
        m.avatarBackground.color = "#FF0000"
      else
        m.itemImage.uri = "pkg:/images/avatar.png"
        m.avatarBackground.color = avatarBackgrounds[rnd(avatarBackgrounds.count()) - 1]
      end if
    end if 


    m.itemText.font.size = "32"

  end function
  
  function init() 
    m.itemImage = m.top.findNode("itemImage") 
    m.itemText = m.top.findNode("itemText") 
    m.avatarBackground = m.top.findNode("avatarBackground") 
  end function