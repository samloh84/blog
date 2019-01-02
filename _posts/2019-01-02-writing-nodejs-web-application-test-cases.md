---
layout: post
title:  "Writing Node.js Web Application Test Cases"
author: samuel
categories: [ testing, application-development ]
image: https://images.unsplash.com/photo-1524347258796-81291228cfc9?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2468&q=80
featured: true
hidden: false
comments: true
---

Continuing on from the [last post]({% post_url 2018-12-19-starting-a-nodejs-express-web-application %}) where I wrote a example Node.js web application, I'll be writing a test framework for it in this post.


Building a Node.js test harness is simple enough. I use [`mocha`](https://mochajs.org/) to run all my test scripts and [`chai`](https://www.chaijs.com/) which allows me to define my test assertions with a nice [expect syntax](https://www.chaijs.com/guide/styles/#expect). To work with promises, I use [`chai-as-promised`](https://github.com/domenic/chai-as-promised). Finally, for testing Express routes, I'm using [`supertest`](https://github.com/visionmedia/supertest).

```bash

npm install --save-dev mocha chai chai-as-promised supertest

```

### Tests Directory Structure
My test scripts go into the `test` directory and running the `mocha --recursive` command will automatically execute all tests found in the `test` directory and its subdirectories.  

For this reason, the structure of my `test` directory will mirror my project directory. If I'm testing a service `services/mongooseService.js`, its test would be in `tests/services/mongooseServiceTest.js`.

`test/services/mongooseServiceTest.js`
```javascript

const chai = require('chai');
const chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);

const expect = chai.expect;
chai.should();

const _ = require('lodash');
const Promise = require('bluebird');
const mongooseService = require('../../services/mongooseService');


describe('mongooseService', function(){
    it('should be able to connect', function(){
        return mongooseService.connect().should.be.fulfilled;
    });

    after(function(){
        mongooseService.disconnect();
    });
});


```

Similarly, DAOs will be tested in a similar manner. If you need to setup database connections or prepare any prerequiste services, do so
in the `beforeEach()` hooks and tear them down in `afterEach()` hooks.

`test/daos/keyValueDaoTest.js`
```javascript

const chai = require('chai');
const chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);

const expect = chai.expect;
chai.should();

const _ = require('lodash');
const Promise = require('bluebird');
const mongooseService = require('../../services/mongooseService');
const keyValueDao = require('../../daos/keyValueDao');

describe('keyValueDao', function(){
    beforeEach(function () {
        return mongooseService.connect();
    });

    afterEach(function () {
        return mongooseService.disconnect();
    });

    it('should be able to retrieve KeyValues', function(){
        return keyValueDao.find().should.eventually.not.empty;
    });

});



```

Testing routes is a little different. Instead of importing the route, we import the Express app and use `supertest` to invoke the route and test the response. 

`test/routes/storeTest.js`
```javascript
const chai = require('chai');
const chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);

const expect = chai.expect;
chai.should();

const _ = require('lodash');
const Promise = require('bluebird');
const request = require('supertest');

const mongooseService = require('../../services/mongooseService');
const keyValueDao = require('../../daos/keyValueDao');
const app = require('../../app');

describe('storeRoute', function () {
    beforeEach(function () {
        return mongooseService.connect();
    });

    afterEach(function(){
        mongooseService.disconnect();
    });

    it('GET /store should return list of keyValues', function () {
        return request(app).get('/store').should.eventually.be.not.empty;
    });

});


```

### The Art of Testing

Creating test cases is relatively easy, given the right frameworks and tooling. That said, your test case suite can grow to a monstrous 1000+ test cases, taking hours to run. The art of testing is creating just the right amount of tests, and that you are testing the right things to test.

* Remember what you should be testing. Testing each module is logical, but be careful that you are not testing trivial functions.

* It's important to prune your test cases regularly. Disable the trivial ones and remove the long-unused test cases.

* Run all tests and ensure that they all pass before you push to your master branch. Don't be that guy that breaks stuff for other people.

Atlassian has a [great article](https://www.atlassian.com/continuous-delivery/software-testing/types-of-software-testing) on the types of software testing and what should be tested.  


