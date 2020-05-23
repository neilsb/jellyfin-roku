sub init()
    m.top.functionName = "getUsers"
end sub

sub getServerInfo()



    ' Load Libraries
    url = "System/Info/Public"
    resp = APIRequest(url)
    data = getJson(resp)


end sub

sub getUsers()

    set_setting("server", m.top.serverUrl)


    users = []

    ' Load Libraries
    url = "users/Public"
    resp = APIRequest(url)
    data = getJson(resp)

    if data = invalid then
        m.top.error = true
        m.top.content = []
        return
    end if

    imgParams = {"maxHeight": 375, "maxWidth": 375 }
    for each item in data
        if item <> invalid AND item.Policy <> invalid AND item.Policy.IsHidden = false then
            tmp = CreateObject("roSGNode", "UserData")
            tmp.json = item

            if item.PrimaryImageTag <> invalid then
                imgParams["Tag"] = item.PrimaryImageTag
                tmp.imageURL = ImageURL(item.id, "Primary", imgParams , "Users")
            end if

            users.push(tmp)
        end if
    end for

    ' Load Latest Additions to Libraries
    m.top.content = users

end sub