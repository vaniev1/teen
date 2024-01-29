const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const messageSchema = new Schema({
  id: String,
  uid: String,
  username: String,
  timestamp: { type: Date, default: Date.now },
  selectedImagePath: String,
  message: String,
});

const Message = mongoose.model('Message', messageSchema);

module.exports = Message;
