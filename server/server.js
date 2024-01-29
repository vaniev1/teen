const express = require('express');
const router = express.Router();
const session = require('express-session');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const mongoose = require('mongoose');
const User = require('./Users');
const Zone = require('./Zone');
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const { v4: uuidv4 } = require('uuid');
const jwt = require('jsonwebtoken');
const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt = require('passport-jwt').ExtractJwt;
const bcrypt = require('bcrypt');
const multer = require('multer');
const path = require('path');
const nodemailer = require('nodemailer');
const sharp = require('sharp');
const fs = require('fs'); // Добавьте эту строку
const Message = require('./Message');
const socketIO = require('socket.io');
const http = require('http');



// Подключение к MongoDB
mongoose.connect('mongodb://localhost/teen', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('Подключение к MongoDB установлено'))
  .catch(err => console.error('Ошибка подключения к MongoDB: ', err));

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.json());


// Настройка express-session
app.use(
  session({
    secret: 'FyHko1wU9yHgsNVpLstlI', // Секретный ключ для подписи сессии (замените на свой секретный ключ)
    resave: false,
    saveUninitialized: false,
  })
);

// Инициализация passport
app.use(passport.initialize());
app.use(passport.session());

passport.use(new JwtStrategy({
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKey: 'FyHko1wU9yHgsNVpLstlI', // Замените на свой секретный ключ
}, (payload, done) => {
  // Здесь проверяйте и верифицируйте токен, затем вызывайте `done` с пользователем, если аутентификация успешна
  // Иначе, вызывайте `done` с ошибкой
  // Пример верификации: (замените на свою логику)
  if (payload && payload.id) {
    return done(null, payload);
  }
  return done('Ошибка аутентификации', false);
}));

// Создание стратегии аутентификации
passport.use(new LocalStrategy(
  {
    usernameField: 'email', // Поле для номера телефона
    passwordField: 'password',
  },
  async (email, password, done) => {
    try {
      const user = await User.findOne({ email: email }).exec();
      if (!user) {
        return done(null, false, { message: 'Пользователь с таким номером телефона не найден' });
      }

      // Сравнение введенного пароля с хешированным паролем в базе данных
      const passwordMatch = await bcrypt.compareSync(password, user.password);

      if (passwordMatch) {
        // Пароль совпадает, передайте пользователя в стратегию
        return done(null, user);
      } else {
        // Пароль не совпадает
        return done(null, false, { message: 'Неверные учетные данные' });
      }
    } catch (error) {
      console.error('Ошибка при поиске пользователя: ', error);
      return done(error);
    }
  }
));


// Сериализация и десериализация пользователя
passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findOne({ _id: id }).exec();
    done(null, user);
  } catch (error) {
    done(error);
  }
});

app.get('/', (req, res) => {
  res.send('Hello, Teen!');
});


const avatarsStaticFilesPath = path.join(__dirname, 'avatars');

// Используйте middleware для обслуживания статических файлов
app.use('/avatars', express.static(avatarsStaticFilesPath));

const avatarsStorage = multer.diskStorage({
  destination: 'avatars/', // specify the directory where you want to save the images
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  },
});

const avatarsUpload = multer({ storage: avatarsStorage });
const zoneAvatarsStaticFilesPath = path.join(__dirname, 'zoneAvatar');

// Используйте middleware для обслуживания статических файлов
app.use('/zoneAvatar', express.static(zoneAvatarsStaticFilesPath));

const zoneAvatarsStorage = multer.diskStorage({
  destination: 'zoneAvatar/', // Укажите каталог, где вы хотите сохранить изображения
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  },
});

const zoneAvatarsUpload = multer({ storage: zoneAvatarsStorage });

app.post('/zone', zoneAvatarsUpload.single('zoneAvatar'), async (req, res) => {
  try {
    const {
      uid,
      fullname,
      username,
      timestamp,
      selectedImagePath,
      zoneTitle,
      zoneDescription,
      selectedTags,
      selectedColor,
    } = req.body;

    let avatar;

    // Проверка, было ли предоставлено изображение или цвет
    if (req.file) {
      avatar = `zoneAvatar/${req.file.filename}`;
    } else if (selectedColor) {
      // Если предоставлен цвет, создайте изображение из цвета и сохраните его
      const colorImagePath = `zoneAvatar/${Date.now()}-color-image.png`;
      const colorImageBuffer = await createColorImage(selectedColor);
      fs.writeFileSync(colorImagePath, colorImageBuffer, { flag: 'w', encoding: 'binary' });
      avatar = colorImagePath;
    } else {
      avatar = null;
    }

    const newZone = new Zone({
      uid,
      fullname,
      username,
      avatar,
      timestamp,
      selectedImagePath,
      zoneTitle,
      zoneDescription,
      selectedTags,
      selectedColor,
      data: { members: [], messages: [] },
    });

    // Добавление создателя зоны в список участников
    const creator = {
      fullname,
      selectedImagePath,
      uid,
      username,
    };
    newZone.data.members.push(creator);

    // Добавление информации о зоне в массив created_zones пользователя
    const zoneInfo = {
      zoneId: newZone._id,
      uid,
      fullname,
      username,
      zoneTitle,
      avatar,
      selectedImagePath,
      zoneDescription,
      selectedTags,
      timestamp,
    };


    const updatedUser = await User.findOneAndUpdate(
      { _id: uid }, // Используем _id вместо uid
      { $push: { "data.created_zones": zoneInfo } },
      { new: true }
    );

    // Дождитесь завершения операции сохранения в базе данных
    const savedZone = await newZone.save();

    res.status(200).json(savedZone);
  } catch (error) {
    console.error('Error in createZone:', error);
    res.status(500).json({ error: 'Server error' });
  }
});




async function createColorImage(color) {
  // Импортируйте библиотеку для работы с изображениями (например, sharp)
  // Создайте изображение из цвета и верните его в виде буфера
  // Пример с использованием sharp:
  const sharp = require('sharp');

  const imageBuffer = await sharp({
    create: {
      width: 100, // Установите ширину и высоту по вашему выбору
      height: 100,
      channels: 4, // RGBA
      background: { r: color.r, g: color.g, b: color.b, alpha: color.a },
    },
  }).png().toBuffer();

  return imageBuffer;
}



app.post('/register', avatarsUpload.single('selectedImage'), async (req, res) => {
  const { email, firstNameLastName, username, password, isChecked } = req.body;

  const selectedImagePath = req.file ? req.file.path : null;

  // Генерация соль (salt) для хеширования пароля
  const saltRounds = 10;
  const salt = await bcrypt.genSalt(saltRounds);

  // Хеширование пароля
  const hashedPassword = await bcrypt.hash(password, salt);

  const newUser = new User({
    Id: uuidv4(),
    email,
    firstNameLastName,
    username,
    password: hashedPassword, // Сохраните хешированный пароль
    selectedImagePath,
    Stata: 0,
    Blocked: false,
    Deleted: false
  });

  newUser.save()
    .then((user) => {
      console.log('Новый пользователь зарегистрирован');

      // Отправка JWT-токена после успешной регистрации
      const token = createToken({
        id: user.id,
        username: user.username,
        firstNameLastName: user.firstNameLastName,
        email: user.email,
        prefix: user.prefix,
        stata: user.stata,
        blocked: user.blocked,
        deleted: user.deleted,
        selectedImagePath: user.selectedImagePath,
        firstReg: user.firstReg, // Добавлено поле firstReg
        lastUse: user.lastUse, // Добавлено поле lastUse
      });

      res.status(200).json({ token });
    })
    .catch(err => {
      console.error('Ошибка при сохранении пользователя: ', err);
      res.status(500).json({ error: 'Ошибка при сохранении пользователя' });
    });
});


app.post('/login', passport.authenticate('local'), (req, res) => {
  const token = createToken(req.user);
  res.status(200).json({ token });
});

// Обновленная функция createToken
function createToken(user) {
  const token = jwt.sign(
    {
      id: user.id,
      username: user.username,
      firstNameLastName: user.firstNameLastName,
      email: user.email,
      prefix: user.prefix,
      stata: user.stata,
      blocked : user.blocked,
      selectedImagePath: user.selectedImagePath,
    },
    'FyHko1wU9yHgsNVpLstlI', // Замените 'ваш_секретный_ключ' на свой секретный ключ
    {
      expiresIn: '365d',
    }
  );
  return token;
}

// Пример защищенного маршрута
app.get('/profile', (req, res) => {
  if (req.isAuthenticated()) {
    // Пользователь аутентифицирован
    res.json({ user: req.user });
  } else {
    res.status(401).json({ error: 'Вы не аутентифицированы' });
  }
});


// Настройка транспорта для отправки почты
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'thevisualapp@gmail.com', // Замените на свой адрес электронной почты
    pass: 'csfy ducz prok caht'   // Замените на свой пароль от почты
  }
});

const confirmationCodes = {}; // Хранение сопоставления email и ожидаемого кода подтверждения

app.use(express.json());
app.use('/assets', express.static(path.join(__dirname, 'assets')));

app.post('/sendConfirmationCode', (req, res) => {
  const { email } = req.body;
  const confirmationCode = Math.floor(100000 + Math.random() * 900000);

  const logoPath = path.join(__dirname, '..', 'assets', 'logo.png');
  const logoData = fs.readFileSync(logoPath);
  const logoBase64 = logoData.toString('base64');

  const mailOptions = {
    from: 'thevisualapp@gmail.com',
    to: email,
    subject: 'Код подтверждения Teen',
    html: `
      <html>
        <head>
          <style>
            .container {
              background-color: black; /* Черный фон */
              color: white; /* Белый цвет текста */
              font-family: Arial, sans-serif;
              text-align: center;
              margin: 0;
              padding: 0;
              padding-bottom: 60px; /* Отступ вниз */
            }

            .logo {
              width: 100px;
            }

            .welcome-message {
              font-size: 18px;
              margin-top: 20px;
            }

            .confirmation-code {
              font-size: 24px;
              font-weight: bold;
              margin-top: 20px;
              color: #7ED957;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <img class="logo" src="data:image/png;base64,${logoBase64}" alt="Логотип приложения">
            <p>Добро пожаловать в новую социальную сеть для общения по интересам!</p>
            <p class="confirmation-code">Ваш код подтверждения: <strong>${confirmationCode}</strong></p>
            <p>Благодарим за регистрацию!</p>
          </div>
        </body>
      </html>
    `,
  };




  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error(error);
      res.status(500).json({ error: 'Ошибка при отправке кода подтверждения' });
    } else {
      console.log('Письмо отправлено: ' + info.response);
      res.status(200).json({ success: true, confirmationCode });
    }
  });
});




app.post('/checkEmail', async (req, res) => { // Изменяем эндпоинт на '/checkEmail'
  try {
    const emailToCheck = req.body.email; // Изменяем поле на 'email'

    const user = await User.findOne({ email: emailToCheck }).exec(); // Изменяем на 'email'

    if (user) {
      // Найден email в базе данных, возвращаем успех
      return res.status(200).json({ message: 'Email найден' });
    } else {
      // Email не найден, возвращаем ошибку
      return res.status(404).json({ error: 'Email не найден' });
    }
  } catch (error) {
    console.error('Ошибка при поиске email:', error);
    return res.status(500).json({ error: 'Ошибка при проверке email' });
  }
});

app.post('/checkUsername', async (req, res) => {
  try {
    const usernameToCheck = req.body.username; // Получаем номер телефона из запроса

    // Вывести номер телефона в консоль для отладки


    // Используем `await` для ожидания результата findOne, который возвращает промис
    const user = await User.findOne({ username: usernameToCheck }).exec();

    if (user) {
      // Найден номер телефона в базе данных, возвращаем успех


      return res.status(200).json({ message: 'username найден' });
    } else {
      // Номер телефона не найден, возвращаем ошибку

      return res.status(404).json({ error: 'username не найден' });
    }
  } catch (error) {
    console.error('Ошибка при поиске username:', error);
    return res.status(500).json({ error: 'Ошибка при проверке username' });
  }
});

app.post('/login', passport.authenticate('local'), (req, res) => {
  // Аутентификация успешна
  // Создаем и отправляем токен
  const token = createToken(req.user);
  res.status(200).json({ token });
});

// Обновленная функция createToken
function createToken(user) {
  const token = jwt.sign(
    {
      id: user.id,
      username: user.username,
      firstNameLastName: user.firstNameLastName,
      mail: user.email,
      prefix: user.prefix,
      stata: user.stata,
      blocked : user.blocked,
      selectedImagePath: user.selectedImagePath,
    },
    'FyHko1wU9yHgsNVpLstlI', // Замените 'ваш_секретный_ключ' на свой секретный ключ
    {
      expiresIn: '365d',
    }
  );
  return token;
}

app.get('/checkBlockedStatus/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findOne({ _id: id });

    if (user && user.blocked) {
      res.status(200).json({ blocked: true });
    } else {
      res.status(200).json({ blocked: false });
    }
  } catch (error) {
    console.error('Error occurred while checking user status: ', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


app.post('/zones', passport.authenticate('jwt', { session: false }), (req, res) => {
  const { uid, fullname, username, zoneTitle, avatar, data } = req.body;

  // Создание новой записи "Zone"
  const newZone = new Zone({
    uid,
    fullname,
    username,
    zoneTitle,
    avatar,
    data,
  });

  // Сохранение новой записи в базе данных
  newZone.save()
    .then((savedZone) => {
      res.status(201).json(savedZone);
    })
    .catch((error) => {
      console.error('Ошибка при создании зоны: ', error);
      res.status(500).json({ error: 'Ошибка при создании зоны' });
    });
});

app.get('/zones', async (req, res) => {
  try {
    const zones = await Zone.find().exec();
    res.status(200).json(zones);
  } catch (error) {
    console.error('Ошибка при получении зон:', error);
    res.status(500).json({ error: 'Ошибка при получении зон' });
  }
});

// Роут для получения всех сообщений для данной зоны
app.get('/zones/:zoneId/messages', async (req, res) => {
  try {
    const { zoneId } = req.params;
    const zone = await Zone.findById(zoneId);

    if (!zone) {
      return res.status(404).json({ error: 'Зона не найдена.' });
    }

    const messages = zone.data.messages;
    res.status(200).json({ messages });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Произошла ошибка при получении сообщений для зоны.' });
  }
});

app.post('/zones/:zoneId/messages', async (req, res) => {
  try {
    const zoneId = req.params.zoneId;
    const { uid, username, selectedImagePath, message } = req.body;

    // Найдите зону по zoneId
    const zone = await Zone.findById(zoneId);

    // Если зона не найдена, верните ошибку 404
    if (!zone) {
      return res.status(404).json({ error: 'Зона не найдена' });
    }

    // Добавьте новое сообщение во вложенный документ messages
    zone.data.messages.push({
      uid,
      username,
      selectedImagePath,
      message,
      timestamp: new Date(),
    });

    // Сохраните обновленный документ в базе данных
    await zone.save();

    res.status(200).json({ message: 'Сообщение успешно добавлено' });
  } catch (error) {
    console.error('Ошибка при добавлении сообщения:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});


//const PORT = 27017;
const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});