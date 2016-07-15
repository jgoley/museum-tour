{ Tour } = require '../../../api/tours/index'
moment   = require 'moment'

require '../views/archivedTours.jade'
require '../../components/thumbnail/thumbnail.coffee'

Template.archivedTours.onCreated ->
  @subscribe 'archivedTour'
  document.title = 'Archived Tour'

Template.archivedTours.helpers
  tours: ->
    Tour.find()
  sinceShow: ->
    moment(@closeDate).fromNow()