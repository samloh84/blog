---
layout: post
title:  "Starting a Node.js Express Web Application"
author: samuel
categories: [ nodejs, express, application-development ]
image: https://images.unsplash.com/photo-1524347258796-81291228cfc9?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2468&q=80
featured: true
hidden: false
comments: true
---

I switched from Java for my primary programming language of choice to NodeJS years ago. At the time, it was being touted as a better option than PHP or Python for quickly implementing a web application.

The suitability of a programming language for use in application development is greatly dependent on the available libraries that allow you to do enterprisey things. For Perl, it was the CPAN modules library that made it useful for writing all manner of scripts and web applications in the past. For Java, the huge amount of libraries available from Maven repositories made it the premier option to implement enterprisey applications (gotta have that export to Microsoft Excel feature, or WS-Security features). NodeJS has definitely surpassed both languages in this regard, with the number of NPM modules exploding into the hundreds of thousands.

For this post I've created an [example project repository on Github](https://github.com/samloh84/node-example-express-app).

### Writing a web application with Express.js 

In the world of programming, it is not an exaggeration to say that there are always newer and better tools and approaches to building a web application being released practically all the time. For this article, I'm gonna outline my basic process.  

I generally use [Express](https://expressjs.com/) as the starting point of my Node.js web applications to serve a REST API. Occasionally, I might use the [Nunjucks](https://mozilla.github.io/nunjucks/) templating library  as my view engine, or I might configure the Express framework to serve a static directory of regular HTML pages. 

The following commands install the Express generator command line utility and generates a Express project.

```bash
npm install --global express-generator

express new-app
```

#### Libraries

I also use the following [Express middleware](https://expressjs.com/en/resources/middleware.html).

| Library | Purpose | npm install |
|---|---|---|
| [morgan](https://www.npmjs.com/package/morgan)<br/>[<sub>Docs</sub>](https://github.com/expressjs/morgan) | Logs requests received by Express | `npm install --save morgan` |
| [multer](https://www.npmjs.com/package/multer)<br/>[<sub>Docs</sub>](https://github.com/expressjs/multer) | Processes multipart requests | `npm install --save multer` |
| [connect-rid](https://www.npmjs.com/package/connect-rid)<br/>[<sub>Docs</sub>](https://github.com/expressjs/connect-rid) | Adds a unique request ID to each header. Good for debugging. | `npm install --save connect-rid` |
| [serve-static](https://www.npmjs.com/package/serve-static)<br/>[<sub>Docs</sub>](https://github.com/expressjs/serve-static) | Enables Express to serve static files | `npm install --save serve-static` |
| [serve-favicon](https://www.npmjs.com/package/serve-favicon)<br/>[<sub>Docs</sub>](https://github.com/expressjs/serve-favicon) | Enables Express to serve a favicon file | `npm install --save serve-favicon` |

For this project, I'll be using the just `morgan`, `multer` and `connect-rid`.
```bash
npm install --save morgan multer connect-rid
```

I usually install some combination of the following libraries that I always end up using in most of projects:

| Library | Purpose | npm install |
|---|---|---|
| [Lodash](https://www.npmjs.com/package/lodash)<br/>[<sub>Docs</sub>](https://lodash.com/) | Utility functions for working with objects and arrays. | `npm install --save lodash` |
| [Moment.js](https://www.npmjs.com/package/moment)<br/>[<sub>Docs</sub>](http://momentjs.com/) | Utility functions for working with date and time. | `npm install --save moment` |
| [bluebird](https://www.npmjs.com/package/bluebird)<br/>[<sub>Docs</sub>](http://bluebirdjs.com/docs/getting-started.html) | My library of choice for working with Promises | `npm install --save bluebird` |
| [SuperAgent](https://www.npmjs.com/package/superagent)<br/>[<sub>Docs</sub>](https://visionmedia.github.io/superagent/) | Library for making HTTP requests | `npm install --save superagent` |
| [Mongoose](https://www.npmjs.com/package/mongoose)<br/>[<sub>Docs</sub>](https://mongoosejs.com/) | Object Document Mapper Library for working with MongoDB | `npm install --save mongoose` |
| [Sequelize](https://www.npmjs.com/package/sequelize)<br/>[<sub>Docs</sub>](https://sequelize.readthedocs.io/en/v3/) | Object relational Mapper Libary for working with SQL databases like PostgreSQL or MySQL | `npm install --save sequelize` |
| [Passport](https://www.npmjs.com/package/passport)<br/>[<sub>Docs</sub>](http://www.passportjs.org/) | Authentication Library to secure your endpoints | `npm install --save passport` |
| [Winston](https://www.npmjs.com/package/winston)<br/>[<sub>Docs</sub>](https://github.com/winstonjs/winston) | Logging Library | `npm install --save winston` |


For this project, I'll be using all of the above libraries except Sequelize and Superagent.

```bash
npm install --save lodash moment bluebird mongoose passport winston
```

#### Project Directories

I also usually create the following directories, as highlighted in my [earlier blog post]({% post_url 2018-12-06-anatomy-of-an-application %})

```bash
cd new-app

mkdir -p \
config \
bin \
routes \
daos \
util \
services \
models
```

#### .gitignore

It's also good to have a `.gitignore` file that excludes configuration secrets, PKI keys, project files generated by my IDE and the invariably large `node_modules` directory.

`.gitignore`
```ignore
# Production Config files
config/*production*.*

# NPM packages
node_modules/

# Jetbrains IntelliJ IDEA files
.idea/

# PKI files
*.pem
*.key
```  

### App Configuration
 
When writing an application that connects to a database, or interacts with a secured API, all of this information is usually stored in a configuration file. I usually write a config loader and import it into my services.

`config/index.js`
```javascript
const _ = require('lodash');
const path = require('path');

const CONFIG_FILE =  _.get(process.env, 'CONFIG_FILE', 'config.js');

const config = require(path.resolve(process.cwd(), 'config', CONFIG_FILE));

module.exports = {
    get: function(key, defaultValue) {
        return _.get(config, key, defaultValue);
    },
    has: function(key) {
        return _.has(config, key);
    },
    env: function(key, defaultValue) {
        return _.get(process.env, key, defaultValue);
    }
};
```

`config/config.js`
```javascript
module.exports = {
    mongodb: {
        host: 'localhost',
        port: 27017,
        database: 'new-app',
    }
};
```

When importing the config, I make sure to check environment variables for configuration overrides, as per the [12-Factor App](https://12factor.net/) spec. This is especially useful when packaging your web application in Docker containers as it enables you to modify configuration at runtime for different environments.

`services/mongooseService.js`
```javascript
const _ = require('lodash');
const Promise = require('bluebird');
const mongoose = require('mongoose');
const models = require('../models');
const config = require('../config/index');
const loggingService = require('./loggingService');

const MONGODB_HOST = config.env('MONGODB_HOST', config.get('mongodb.host', 'localhost'));
const MONGODB_PORT = config.env('MONGODB_PORT', config.get('mongodb.port', 27017));
const MONGODB_USERNAME = config.env('MONGODB_USERNAME', config.get('mongodb.username'));
const MONGODB_PASSWORD = config.env('MONGODB_PASSWORD', config.get('mongodb.password'));
const MONGODB_DATABASE = config.env('MONGODB_DATABASE', config.get('mongodb.database'));

mongoose.Promise = Promise;

const mongooseService = {
    mongoose: mongoose
};

_.forIn(models, function (schema, name) {
    mongoose.model(name, schema);
});

mongooseService.connect = function () {
    let mongodbUrl = `mongodb://`;

    if (!_.isNil(MONGODB_USERNAME) && !_.isNil(MONGODB_PASSWORD)) {
        mongodbUrl += `${MONGODB_USERNAME}:${MONGODB_PASSWORD}@`;
    }

    mongodbUrl += `${MONGODB_HOST}:${MONGODB_PORT}`;

    if (!_.isNil(MONGODB_DATABASE)) {
        mongodbUrl += `/${MONGODB_DATABASE}`;
    }


    return mongoose.connect(mongodbUrl, {useNewUrlParser: true})
        .tap(function () {
            let mongodbUrl = `mongodb://`;

            if (!_.isNil(MONGODB_USERNAME) && !_.isNil(MONGODB_PASSWORD)) {
                mongodbUrl += `${MONGODB_USERNAME}@`;
            }

            mongodbUrl += `${MONGODB_HOST}:${MONGODB_PORT}`;

            if (!_.isNil(MONGODB_DATABASE)) {
                mongodbUrl += `/${MONGODB_DATABASE}`;
            }

            loggingService.info(`Connected to MongoDB server:\n` + mongodbUrl)
        });
};

module.exports = mongooseService;
```

### Logging

I always setup a logging service to give me flexibility to send my logs to external log collection endpoints. As I frequently use Docker containers, and as per [12-Factor Application](https://12factor.net/) standards, I usually send all logs to `STDOUT``` and ```STDERR` by default.

`services/loggingService.js`
```javascript
const _ = require('lodash');
const winston = require('winston');
const config = require('../config/index');

const NODE_ENV = config.env('NODE_ENV', 'development');
const LOGGING_LEVEL = config.env('LOGGING_LEVEL', config.get('logging.level', NODE_ENV === 'production' ? 'debug' : 'info'));

const format = winston.format;

const loggingService = winston.createLogger({
    level: LOGGING_LEVEL,
    format: winston.format.json(),
    transports: [
        new winston.transports.Console({
            format: format.combine(
                format.timestamp(),
                format.colorize(),
                format.simple()
            )
        })
    ]
});

module.exports = loggingService;
```

### The main App 

I customize the Express app.js to include all my middleware. I also wire up the `routes` import, where all my controller logic will be placed for each REST API endpoint I define.

`app.js`
```javascript
const express = require('express');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const createError = require('http-errors');
const loggingService = require('./services/loggingService.js');
const rid = require('connect-rid');
const morgan = require('morgan');

const routes = require('./routes');

const app = express();

app.use(bodyParser.json());
app.use(cookieParser());
app.use(rid());
app.use(morgan('combined',{
    stream: {
        write: function (message) {
            return loggingService.info(message.trim());
        }
    }
}));

app.use(routes);

app.use(function (req, res, next) {
    return next(new createError(404));
});

app.use(function (err, req, res, next) {

    loggingService.error(err.stack);

    res.status(err.status || 500);
    return res.jsonp({
        status: err.status || 500,
        message: err.message
    });

});

module.exports = app;
```

### Routes

Most of the business logic of the application goes into my routes. Each route trigger a function in the dao or services layers and returns a JSON response. 

`routes/index.js`
```javascript
const express = require('express');
const router = express.Router();


router.get('/', function (req, res, next) {
    return res.jsonp({status: 'OK'});
});

// Routes can be broken up into individual files,
// imported and used as follows. 

router.use('/store', require('./store'));

module.exports = router;
```

The following is an example route that exposes a REST API for working with a domain object.

`routes/store.js`
```javascript
const _ = require('lodash');
const express = require('express');
const router = express.Router();

const keyValueDao = require('../daos/keyValueDao');

router.get('/', function (req, res, next) {
    let limit = _.get(req.query, 'limit');
    let skip = _.get(req.query, 'skip');

    return keyValueDao.find(null, null, {limit: limit, skip: skip, sort: 'key'})
        .then(function (keyValues) {
            keyValues = _.map(keyValues, function (keyValue) {
                return keyValue.toObject();
            });
            return res.jsonp(keyValues);
        })
        .catch(function (err) {
            return next(err);
        });
});

router.get('/:key', function (req, res, next) {
    let key = _.get(req.params, 'key');
    return keyValueDao.findOne({key: key})
        .then(function (keyValue) {
            return res.jsonp(keyValue.toObject());
        })
        .catch(function (err) {
            return next(err);
        });
});

router.post('/', function (req, res, next) {
    let keyValue = _.pick(req.body, ['key', 'value']);

    return keyValueDao.create(keyValue)
        .then(function (keyValue) {
            return res.jsonp(keyValue.toObject());
        })
        .catch(function (err) {
            return next(err);
        });
});


router.put('/:key', function (req, res, next) {
    let key = _.get(req.body, 'key');
    let value = _.get(req.body, 'value');

    return keyValueDao.findOneAndUpdate({key: key}, {value: value}, {upsert: true})
        .then(function (keyValue) {
            return res.jsonp(keyValue.toObject());
        })
        .catch(function (err) {
            return next(err);
        });
});


router.delete('/:key', function (req, res, next) {
    let key = _.get(req.body, 'key');

    return keyValueDao.findOneAndDelete({key: key})
        .then(function (keyValue) {
            return res.jsonp(keyValue.toObject());
        })
        .catch(function (err) {
            return next(err);
        });
});

module.exports = router;
```

### Models

I earlier setup a `models` import into my `services/mongooseService.js`. You can define rich models in Mongoose with validation, instance and static functions. For ease of creation of the schemas, I import and re-export them in an object that I can loop over to instantiate the Mongoose schemas.

`models/index.js`
```javascript
module.exports = {
    KeyValue: require('./KeyValue')
};
```

`models/KeyValue.js`
```javascript
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const KeyValue = new Schema({
    key: {
        type: String,
        unique: true
    },
    value: Schema.Types.Mixed
});

module.exports = KeyValue;
```


### Express Starting script

I also heavily modify the Express starting script, so that I can support TLS and import all my services. I also implement a listener to exit the application when the `SIGTERM` process signal is received, as per [12-Factor Application](https://12factor.net/) standards.

`bin/www.js`
```javascript

const _ = require('lodash');
const path = require('path');
const fs = require('fs');
const http = require('http');
const https = require('https');
const config = require('../config');
const mongooseService = require('../services/mongooseService');
const loggingService = require('../services/loggingService');
const Promise = require('bluebird');
const app = require('../app');

app.locals.config = config;
app.locals.mongooseService = mongooseService;
app.locals.loggingService = loggingService;

Promise.all([
    mongooseService.connect()
]).then(function(){
    const TLS_CERT = config.env('TLS_CERT', config.get('tls.cert'));
    const TLS_KEY = config.env('TLS_KEY', config.get('tls.key'));
    
    let serverPort, server;
    if (!_.isNil(TLS_CERT) && !_.isNil(TLS_KEY)){
        serverPort = config.env('PORT', config.get('port'), 8443);
        let tlsOptions = {
            key: fs.readFileSync(path.resolve(process.cwd(), TLS_KEY)),
            cert: fs.readFileSync(path.resolve(process.cwd(), TLS_CERT))
        };
        server = https.createServer(tlsOptions, app);       
    } else{
        serverPort = config.env('PORT', config.get('port'), 8080);
        server = http.createServer(app);
    }
    server.listen(serverPort);
    
    process.once('SIGTERM', function () {
        logger.info("SIGTERM received. Terminating");
        server.close(function () {
            process.exit(0);
        });
    });

    process.on('uncaughtException', function (err) {
        logger.error(err.stack);
    });

    process.on('unhandledRejection', function (err) {
        logger.error(err.stack);
    });

});

```

From the project root directory, I can run the following command to start the application.

```bash
node bin/www.js
```

For development, it's useful to restart the application whenever you make changes. Using [`nodemon`](https://github.com/remy/nodemon) helps in this regard.

```bash
npm install --global nodemon

nodemon bin/www.js
```
 

### Docker

I also usually write a Dockerfile to package the application. Following this [helpful guide from Node.JS](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)

`Dockerfile`
```dockerfile
FROM node:latest

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . ./

EXPOSE 8443
EXPOSE 8080

CMD node bin/www.js
```

A `.dockerignore``` file is useful to prevent the humongous ```node_modules` directory from being sent to the Docker host every time you build the Docker image.
`.dockerignore`
```ignore
node_modules/
npm-debug.log
```

It's also useful to create a `docker-compose.yml` to make it easier to build and run your application services.

`docker-compose.yml`
```yaml
version: '3.2'

services:
  app:
    build: .
    image: new-app:latest
    env_file: ./.env
    restart: unless-stopped
    volumes:
      - type: volume
        source: new-app
        target: /usr/src/app/storage
    environment:
      MONGODB_HOST: mongo
      MONGODB_DATABASE: new-app
    ports:
      - "80:8080"
    networks:
      - new-app
    depends_on:
      - mongo

  mongo:
    restart: unless-stopped
    image: mongo:latest
    volumes:
      - type: volume
        source: mongo
        target: /data/db
    ports:
      - "27017:27017"
    networks:
      - new-app

volumes:
  new-app:
  mongo:

networks:
  new-app:
```

With the above docker-compose.yml in place, I can run the application together with a supporting MongoDB instance with the following command:
```bash
docker-compose up
```

Just to make Docker building a bit faster, it's good to have a `.dockerignore` file to prevent the `node_modules` directory from being included in the Docker build.
`.dockerignore`
```ignore
node_modules/
```

### Other resources

I also use these libraries for special purpose projects.
 
| Library  | Purpose | npm install |
|---|---|---|
| [Cheerio](https://www.npmjs.com/package/cheerio)<br/>[<sub>Docs</sub>](https://github.com/cheeriojs/cheerio) | Library for parsing other HTML content | `npm install --save cheerio` |
| [Forge](https://www.npmjs.com/package/node-forge)<br/>[<sub>Docs</sub>](https://github.com/digitalbazaar/forge) | Library for working with cryptography and PKI | `npm install --save node-forge` |
| [Commander](https://www.npmjs.com/package/commander)<br/>[<sub>Docs</sub>](https://tj.github.io/commander.js/) | Library for writing command line apps | `npm install --save commander` |
| [Telegraf](https://www.npmjs.com/package/telegraf)<br/>[<sub>Docs</sub>](https://github.com/telegraf/telegraf) | Library for writing Telegram bots | `npm install --save telegraf` |

Occasionally I do peruse the [Awesome Node.js](https://github.com/sindresorhus/awesome-nodejs) for inspiration or for useful libraries.
