import { Mongo } from 'meteor/mongo'
import { Class } from 'meteor/jagi:astronomy'
# import { showNotification} from '../../helpers/notifications'
import { classEvents } from '../../helpers/class_helpers'
# import { formatFileName } from '../../helpers/files'

Assets = new Mongo.Collection 'assets'

Asset = Class.create
  name: 'Asset'
  collection: Assets
  secured: false
  fields:
    name:
      type: String
      optional: true
    fileName:
      type: String
      optional: true
    type:
      type: String
      optional: true
    location:
      type: String
      optional: true

  behaviors:
    timestamp:
      hasCreatedField: true
      createdFieldName: 'createdAt'
      hasUpdatedField: true
      updatedFieldName: 'updatedAt'

  events: classEvents

  helpers:
    delete: ->
      new Promise (resolve) =>
        S3.delete "#{@location}#{@fileName}", (error, res) =>
          if error
            showNotification error
          else
            @softRemove()
            resolve()
    upload: (file, path) ->
      new Promise (resolve) =>
        S3.upload
          file       : file
          unique_name: false
          path       : path
          (error, response) ->
            if error
              showNotification error
            resolve()
  behaviors: {
    softremove: {
       # The field name with a flag for marking a document as removed.
      removedFieldName: 'removed',
       # A flag indicating if a "removedAt" field should be present in a document.
      hasRemovedAtField: true,
       # The field name storing the removal date.
      removedAtFieldName: 'removedAt'
    }
  }

module.exports =
  Asset : Asset
