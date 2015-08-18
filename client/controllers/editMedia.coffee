Tours = ()->
  @Tap.Collections.Tours

TourStops = ()->
  @Tap.Collections.TourStops

deleteFile = (prop, fileName, stopID, tourID)->
  path = "/#{tourID}/#{fileName}"
  console.log path
  S3.delete(path, (e,s)-> console.log e,s)
  newProp = {}
  newProp[prop] = ''
  console.log prop, fileName, stopID, tourID, newProp
  if stopID
    TourStops().update({_id: stopID}, {$set:newProp})
  else
    Tours().update({_id: tourID}, {$set:newProp})

Template.editMedia.helpers
  'mediaIsImage': ->
    image = ['image', 3, '3']
    @currentMediaType in image
  'mediaisVideo': ->
    video = ['video', 2, '2']
    @mediaType?.get() in video

Template.editMedia.events
  'click .delete-media': (e, template) ->
    deleteFile('media', @stop.media, @stop._id, @stop.tour)
  'click .delete-image': (e, template) ->
    deleteFile(@name, @media, false, @tourID)