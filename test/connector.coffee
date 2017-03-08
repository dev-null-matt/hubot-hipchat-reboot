chai = require 'chai'
sinon = require 'sinon'

chai.use require 'sinon-chai'

{Connector,onStanza} = require '../src/connector'

describe "Unit tests:", ->
  beforeEach ->
    @jabber =
      logger:
        info: ->
        debug: ->
      onStanza: onStanza
      emit: sinon.spy()

  it "can construct a Connector", ->
    connector = new Connector
      jid: "123123@chat.hipchat.com"

  it "onStanza group message emits correct events", ->
    stanza =
      attrs: {type: "groupchat", from: "123123_foo@conf.hipchat.com/matt"}
      is: -> "message"
      getChild: (type) -> return if type isnt "delay" then "foo" else false
      getChildText: (type) -> type

    @jabber.onStanza stanza

    sinon.assert.callCount(@jabber.emit, 2)
    sinon.assert.calledWith(@jabber.emit, "data", stanza)
    sinon.assert.calledWith(@jabber.emit, "message", "123123_foo@conf.hipchat.com", "matt", "body")

  it "onStanza private message emits proper events", ->

    stanza =
      attrs: {type: "chat", from: "432432_123123@chat.hipchat.com/matt"}
      is: -> "message"
      getChild: (type) -> return if type isnt "delay" then "foo" else false
      getChildText: (type) -> type

    @jabber.onStanza stanza

    sinon.assert.callCount(@jabber.emit, 2)
    sinon.assert.calledWith(@jabber.emit, "data", stanza)
    sinon.assert.calledWith(@jabber.emit, "privateMessage", "432432_123123@chat.hipchat.com", "body")
