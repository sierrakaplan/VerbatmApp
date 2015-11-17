var express = require('express')
  , http = require('http')
  , path = require('path')
	, session = require('express-session')
  , hbs = require('express3-handlebars')
  , bodyParser = require('body-parser')
  , methodOverride = require('method-override')
  , morgan = require('morgan')
  , cookieParser = require('cookie-parser')
  , errorHandler = require('errorhandler')
  , favicon = require('favicon');

var index = require('./routes/index');
var email = require('./routes/email');
var storyviewer = require('./routes/storyviewer');

var app = express();
var env = process.env.NODE_ENV || 'development';

// configure stuff here
app.set('port', (process.env.PORT || 3000))
app.set('views', path.join(__dirname, 'views'));
app.engine('handlebars', hbs());
app.set('view engine', 'handlebars');
app.use(cookieParser());
// app.use(favicon());
var store = new session.MemoryStore;
app.use(session({secret: "SECRET", store: store,
  saveUninitialized: true,
  resave: true}));
app.use(morgan('dev'));
app.use(bodyParser.urlencoded({extended: false}))    // parse application/x-www-form-urlencoded
app.use(bodyParser.json())    // parse application/json
app.use(methodOverride());
app.use(express.static(path.join(__dirname, 'public')));
if ('development' == env) {
  app.use(errorHandler());
} 

// Setup Routes
app.get('/', index.view);
app.get('/v/:pov_id', storyviewer.view);
app.post('/email', email.sendEmail);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});