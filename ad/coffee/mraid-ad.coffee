###
# @authors Ohad Kravchick & Trevor Landau
###

do (root = window, parent = window.parent) ->
    "use strict"

    class AdContainer
        constructor: () ->

        _getParam: (paramName) ->
            params = window.location.search.slice(1).slice(0, -1).split("&")

            for param in paramsArr
                kvArr = param.split("=")
                if kvArr[0] == paramName
                    return kvArr[1]

        hasGeo: () ->
            #@_getParam("geo") == "true"
            return true

        getGeoLocation: (cb) ->
            @_on (resp) ->
                console.log resp
                if resp.type == "geoResponse"
                    cb(resp.data)
            @_post({type: "geoRequest"})

        # Listen to messages from parent
        _on: (cb, resp) ->
            root.addEventListener "message", (e) =>
                cb(e.data)
                if resp then e.source.postMessage(resp, e.origin)
            , false

        # Post a message to parent
        _post: (msg) ->
            parent.postMessage(msg, "*")

    root.adContainer = new AdContainer()
