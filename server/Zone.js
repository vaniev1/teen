const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const zoneSchema = new mongoose.Schema({
  id: String,
  uid: String,
  fullname: String,
  username: String,
  zoneTitle: String,
  avatar: String,
  selectedImagePath : String,
  zoneDescription: String,
  selectedTags: String,
  timestamp: { type: Date, default: Date.now },
      data: {
        members: [{fullname: String, selectedImagePath: String, uid : String, username : String}],
        messages: [{uid: String, username: String, timestamp: {type: Date, default: Date.now}, selectedImagePath: String, message:String}],
      },
});

const Zone = mongoose.model('Zone', zoneSchema);

module.exports = Zone;