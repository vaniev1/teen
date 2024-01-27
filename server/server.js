const express = require('express');
const router = express.Router();
const session = require('express-session');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const mongoose = require('mongoose');
const User = require('./Users');
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
  res.send('Hello, Vizzie!');
});


const avatarsStaticFilesPath = path.join(__dirname, 'avatars');

// Используйте middleware для обслуживания статических файлов
app.use('/avatars', express.static(avatarsStaticFilesPath));

const storage = multer.diskStorage({
  destination: 'avatars/', // specify the directory where you want to save the images
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  },
});

const upload = multer({ storage: storage });

app.post('/register', upload.single('selectedImage'), async (req, res) => {
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

// Эндпоинт для отправки кода подтверждения
app.post('/sendConfirmationCode', (req, res) => {
  const { email } = req.body;

  // Генерация шестизначного кода
  const confirmationCode = Math.floor(100000 + Math.random() * 900000);

  confirmationCodes[email] = confirmationCode;


  // Настройка содержания письма
  const mailOptions = {
    from: 'thevisualapp@gmail.com',  // Замените на свой адрес электронной почты
    to: email,
    subject: 'Код подтверждения регистрации',
    text: `Ваш код подтверждения: ${confirmationCode}`
  };

  // Отправка письма
  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error(error);
      res.status(500).json({ error: 'Ошибка при отправке кода подтверждения' });
    } else {
      console.log('Письмо отправлено: ' + info.response);
      res.status(200).json({ success: true, confirmationCode }); // Отправляем код в ответе
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



//const PORT = 27017;
const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});