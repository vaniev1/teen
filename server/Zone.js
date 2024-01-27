const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const zoneSchema = new mongoose.Schema({
  uid: String,
  fullname: String,
  username: String,
  zoneTitle: String,
  avatar: String,
  timestamp: { type: Date, default: Date.now },
      data: {
        members: [{fullname: String, selectedImagePath: String, uid : String, username : String}],
      },
});

const Zone = mongoose.model('Zone', zoneSchema);

module.exports = Zone;