class TwitterExample
  constructor: ->
    @outputElement = '#output'
    @load_views()
    $.ajaxSetup timeout: 10000 # don't let ajax calls run forever - global default
    @check_status()

  check_status: ->
    result = $.getJSON "/auth/status.json"
    result.done (data) =>
      @renderView(@outputElement,"tweets", {name: data.name})
      @fetch_tweets()
    result.fail (data) =>
      @auth_error(data)

  fetch_tweets: ->
    result = $.getJSON "/auth/tweets.json"
    result.done (data) =>
      @renderView(@outputElement,"tweets", {name: data.name, tweets: data.tweets})
    result.fail (data) =>
      @auth_error(data)

  auth_error: (data) ->
    if data.status == 401
      payload = JSON.parse(data.responseText)
      unless payload? and payload.authUrl
        @renderView(@outputElement,"error", { message: "Unexpected error payload:", data: JSON.stringify({payload: payload, response: data}, null, 4) })
      else
        @renderView(@outputElement,"noauth", payload)
    else
      @renderView(@outputElement,"error", { message: "Unexpected error:", data: JSON.stringify(data, null, 4) })

  # following is more generic stuff for views, data loading etc - not twitter-example specific
  load_views: ->
    that = this
    that.views = {}
    $(".view-template").each ->
       name = $(this).attr("data-name")
       that.views[name] = Handlebars.compile($(this).html())

  renderView: (element, name, data) ->
    throw new Error("no such view: #{name}") unless @views[name]
    view = @views[name](data)
    $(element).html(view)

# expose a namespace for external use
root = global ? window
root.TwitterExample = TwitterExample

$( ->
  # construct (and so start) an instance on page load
  root.twitterExample = new TwitterExample
)