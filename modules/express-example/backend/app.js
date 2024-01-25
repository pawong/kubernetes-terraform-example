var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

const swaggerJsdoc = require('swagger-jsdoc')
const swaggerUi = require('swagger-ui-express')

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');
var eballRouter = require('./routes/eball');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', usersRouter);
app.use('/8ball', eballRouter);

// swagger
const options = {
  swaggerDefinition: {
    openapi: '3.0.0',
    info: {
      title: 'Express Example',
      version: '1.0.0',
      description: 'Express example on Kubernetes',
    },
    // servers: [
    //   {
    //     url: 'http://localhost:3000',
    //   },
    //   {
    //     url: 'http://express.example.com'
    //   }
    // ],
  },
  apis: [path.join(process.cwd(), '/routes/*.js')]
}
const specs = swaggerJsdoc(options);
app.use(
  "/docs",
  swaggerUi.serve,
  swaggerUi.setup(specs, { explorer: true })
);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
