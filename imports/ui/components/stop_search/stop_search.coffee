{ ReactiveVar } = require 'meteor/reactive-var'
{ TourStop }   = require '../../../api/tour_stops/index'
{ go }          = require '../../../helpers/route_helpers'

require './stop_search.jade'

Template.stopSearch.onCreated ->
  @buttonState = new ReactiveVar(true)
  @stops = @data.stops

Template.stopSearch.events
  'input .stopNumber': (e, instance) ->
    if TourStop.findOne(stopNumber: +e.target.value)
      instance.buttonState.set false
    else
      instance.buttonState.set true

  'submit .goto-stop': (e, instance) ->
    e.preventDefault()
    stop = TourStop.findOne stopNumber: +e.target.stopNumber.value
    go 'stop', {'tourID': stop.tour, 'stopID': stop._id}

Template.stopSearch.helpers
  buttonState: ->
    Template.instance().buttonState.get()