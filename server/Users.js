const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const userSchema = new mongoose.Schema({
  firstNameLastName: String,
  username: String,
  password: String,
  email: String, // Добавляем поле для номера телефона
  prefix: String,
  stata: { type: Number, default: 0 },
  blocked: { type: Boolean, default: false },
  deleted: { type: Boolean, default: false },
  firstReg: { type: Date, default: Date.now },
  lastUse: { type: Date, default: Date.now },
  selectedImagePath: String,
    data: {
      blocked_users : [{userId : String}],
      blocked_to : [{currentUserId : String}],
    },
});

const User = mongoose.model('User', userSchema);

module.exports = User;