{ TourStops }        = require '../../../api/tour_stops/index'
{ showNotification } = require '../../../helpers/notifications'
{ Session }          = require 'meteor/session'
{ updateStop }       = require '../../../helpers/edit'

Template.editStop.onCreated ->
  @activelyEditing = new ReactiveVar false
  @subscribe 'childStops', @data.stop._id

Template.editStop.helpers
  editStop: ->
    Template.instance().activelyEditing.get()

  showChildStops: ->
    console.log "test", Template.instance().activelyEditing.get()
    Template.instance().activelyEditing.get()

  sortableOptions : ->
    handle: '.handle'

  editChildStop: (parent) ->
    Session.get("child-" + @stop.parent + '-' + @stop._id)

  isGroup: ->
    @stop.type is 'group'

  children: ->
    @stop.children()

  addChild: ->
    Session.get('add-child-'+@stop._id)

  showAddStop: ->
    Session.get('add-stop')

  hasMedia: (stopID) ->
    TourStops.findOne({_id: stopID}).media

  activelyEditing: ->
    Template.instance().activelyEditing


Template.editStop.events
  'click .convert-group': () ->
    convertStop = confirm('Are you sure you want to convert this stop to a group?')
    if convertStop
      currentStop = @stop
      newChild = _.clone currentStop
      delete newChild._id
      delete newChild.stopNumber
      newChild.parent = currentStop._id
      newChild.type = 'child'
      newChild.order = 1
      parentQuery = "}, {$set: {type: 'group'}}"
      TourStops.insert newChild, (e, id) ->
        TourStops.update {_id: currentStop._id}, {$set: {type:'group', childStops: [id]}, $unset: {media: '', mediaType: '', speaker: ''}}, (e,r) ->
          showNotification(e)

  'click .convert-single': () ->
    convertStop = confirm('Are you sure you want to convert this stop to a single stop?')
    if convertStop
      that = @
      lastStopNumber = _.last(Template.instance().data.stops.fetch()).stopNumber
      TourStops.update {_id: that.stop.parent}, {$pull:{childStops: that.stop._id}}, () ->
        showNotification(e)

  'click .add-child': () ->
    Session.set('add-child-'+@_id, true)

  'submit .edit-stop': (e, instance) ->
    # $(e.target).addClass('saved')
    e.preventDefault()
    Session.set('updating'+@stop._id, true)
    form = e.target
    mediaType = form.mediaType?.value
    files = []
    _.each $(form).find("[type='file']"), (file) ->
      if file.files[0] then files.push(file.files[0])
    values =
      values:
        speaker: form.speaker?.value
        mediaType: mediaType
        order: +form.order?.value
        tour: @stop?.tour
      files: files

    if files.length
      if form.media?.files[0]
        values.values.media = form.media.files[0]?.name.split(" ").join("+")
      if mediaType is '2' and form.posterImage?.files[0]
        values.values.posterImage = form.posterImage.files[0].name.split(" ").join("+")

    updateStop(@stop, values, 'update')

  'click .hide-children': (e)->
    Session.set("childStops" + @_id,false)
    parent = @
    _.chain(Template.instance().data.childStops.fetch())
      .filter((childStops) -> childStops.parent == parent._id)
      .each((child) -> Session.set("child-" + child.parent + '-' + child._id, false))

  'click .show-add-stop': ()->
    Session.set('add-stop', true)
    setTimeout (->
      $('html, body').animate({ scrollTop: $(".add-stop").offset().top - 55 }, 800)
      ), 0

  'click .cancel-add-stop': ()->
    Session.set('add-stop', false)

  'click .delete': (e)->
    if @type is 'group'
      deleteStop = confirm('Are you sure you want to delete this stop?\nAll child stops will also be deleted!')
    else
      deleteStop = confirm('Are you sure you want to delete this stop?')
    if deleteStop
      if @type is 'group'
        Meteor.call 'removeGroup', @childStops
      else if @type is 'single'
        if @media
          deleteFile(@)
        TourStops.remove({_id: @_id})
      else
        that = @
        siblings = _.filter Template.instance().data.childStops.fetch(), (stop) ->
          stop.parent is that.parent
        higherSiblings = _.filter siblings, (stop) ->
          stop.order > that.order
        _.each higherSiblings, (stop) ->
          TourStops.update {_id: stop._id}, {$set: {order: stop.order-1}}
        TourStops.update({_id: @parent}, {$pull: {childStops: @_id}})
        TourStops.remove({_id: @_id})
