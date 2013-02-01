###
# @authors Ohad Kravchick & Trevor Landau
###

do (root = window, d = window.document) ->
    "use strict"

    class AdService
        constructor: ->
        _getLastPos: (cb) =>
            navigator.geolocation.getCurrentPosition (pos) =>
                cb(pos)
        loadAdIntoEl: (el, {height, width, geo}, cb) =>
            geo = false if geo != true
            if geo
                adUrl = "http://localhost:8001?geo=true"
            else
                adUrl = "http://localhost:8001?geo=false"

            ad = new Ad(adUrl, el, {geo})
            ad.loadAd =>
                cb()

            ad.on (data) =>
                if data.type == "geoRequest"
                    @_getLastPos (pos) =>
                        ad.post({ type: "geoReply", pos: pos})
    class Ad
        constructor: (@url, el) ->
            @_createIframe()
            @el = d.querySelector(el)
            unless @el then throw new Error "Element `#{el}` not found"

        loadAd: (cb, resp) ->
            @on (data) =>
                cb(data)
            , resp

            @_iframe.src = @url
            @_placeAd()

        _createIframe: =>
            @_iframe = d.createElement("iframe")

        _placeAd: =>
            @el.appendChild(@_iframe)

        # Listen to messages from the ad
        on: (cb, resp) ->
            root.addEventListener "message", (e) =>
                if e.origin != @url then return
                cb(e.data)
                if resp then e.source.postMessage(resp, e.origin)
            , false

        # Post a message to the ad
        post: (msg) =>
            @_iframe.contentWindow.postMessage(msg, "http://localhost:8001")

    root.AdService = new AdService()
