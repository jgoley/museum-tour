{ Tour }     = require '../../../api/tours/index'
{ TourStop } = require '../../../api/tour_stops/index'

require '../views/currentTours.jade'
require '../../components/thumbnail/thumbnail'
require '../../components/stop_search/stop_search.coffee'

Template.currentTours.onCreated ->
  @subscribe 'currentTour'
  @subscribe 'currentTourStops'
  document.title = 'Current Tour'

Template.currentTours.helpers
  tours: ->
    Tour.find()
  stopNumbers: ->
    TourStop.find()
