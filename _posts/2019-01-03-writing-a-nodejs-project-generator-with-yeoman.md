---
layout: post
title:  "Writing a Node.js Project Generator with Yeoman"
author: samuel
categories: [ nodejs, yeoman, code-generation, application-development ]
image: https://images.unsplash.com/photo-1524347258796-81291228cfc9?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2468&q=80
featured: true
hidden: false
comments: true
---

While writing [my post on starting a Node.js application]({% post_url 2018-12-19-starting-a-nodejs-express-web-application %}), I was already looking around for a solution that creates projects from a boilerplate.

[Yeoman](https://yeoman.io) is a Node.js command line utility that offers several [generators]((https://yeoman.io/generators/)). It even offers a [generator](https://github.com/yeoman/generator-generator) to create Yeoman generators.

![A fine image from Yeoman's generator-generator Github page](https://camo.githubusercontent.com/f8dc3e07d956f1f8dbdea5f895800fe53772a50d/687474703a2f2f692e696d6775722e636f6d2f326771696966742e6a7067)
<sub>A fine image from Yeoman's generator-generator Github page</sub>

To begin with, install Yeoman and the generator-generator, which generates generator projects. Then create your project directory, which should be prefixed with the word `generator-`.
Then invoke the generator-generator with the `yo generator` command.

```bash
npm install -g yo generator-generator
mkdir -p generator-node-express-application
cd generator-node-express-application
yo generator
```

[Yeoman Documentation on writing a generator](https://yeoman.io/authoring/)

The generator has this directory structure:
```text
project_dir
├── generators/
│   └── app/
│       ├── templates/
│       └── index.js
└── package.json
```


I'm going to modify the generator to simply copy files from the templates directory into the target project directory. This way, I can copy all
of the source code for my Express application into the `templates` directory.

It is possible to use EJS templates to dynamically render text files, but I'm not going to go down that rabbit hole. Similarly, I'm not going to dynamically create Javascript code  for this project. Not yet, anyway...

When copying the package.json, I am going to dynamically modify it, asking the same questions that `npm init` would ask. Since all the dependencies are already listed in package.json, the generators final internal `npm install` will install all the dependencies.

`generators/app/index.js`
'use strict';
const Generator = require('yeoman-generator');
const Promise = require('bluebird');
const _ = require('lodash');
const glob = Promise.promisify(require('glob'));

module.exports = class extends Generator {

  prompting() {
    this.log('Node.js Express Application Generator');

    const prompts = [
      {
        type: 'input',
        name: 'name',
        message: 'package name:',
        default: this.appname
      },
      {
        type: 'input',
        name: 'version',
        message: 'version:',
        default: '1.0.0'
      },
      {
        type: 'input',
        name: 'description',
        message: 'description:',
      },
      {
        type: 'input',
        name: 'gitRepository',
        message: 'git repository:',
      },
      {
        type: 'input',
        name: 'keywords',
        message: 'keywords:',
      },
      {
        type: 'input',
        name: 'author',
        message: 'author:',
      },
      {
        type: 'input',
        name: 'license',
        message: 'license:',
        default: 'MIT'
      },
    ];

    return this.prompt(prompts).then(props => {
      this.props = props;
    });
  }

  writing() {
    const generator = this;
    const fs = generator.fs;
    const props = generator.props;

    return glob('**/*.*', {
      cwd: generator.templatePath(),
      dot: true,
      ignore: ['package-lock.json']
    })
      .each(function (file) {
        let templatePath = generator.templatePath(file);
        let destinationPath = generator.destinationPath(file);

        if (file === 'package.json') {
          const packageJson = fs.readJSON(templatePath);

          _.assign(packageJson, {
            "name": `${props.name}`,
            "version": `${props.version}`,
            "description": `${props.description}`,
            "author": `${props.author}`,
            "license": `${props.license}`
          });

          if (!_.isEmpty(props.keywords)) {
            packageJson.keywords = props.keywords.split(/s+/);
          }

          if (!_.isEmpty(props.gitRepository)) {
            packageJson.git = {type: git, url: props.gitRepository};
          }

          fs.writeJSON(packageJson, destinationPath);

        } else {
          fs.copyTpl(templatePath, destinationPath);
        }

      });
  }

  install() {
    this.installDependencies({bower: false});
  }
};
```

### Testing the Generator

To test the generator, npm needs to know about it. At the root of your generator project:
```bash
npm link
```

You can then test the generator by running the following command in an empty directory.
```bash
yo node-express-app

```

### Publishing to NPM
I am going to use [NPM scoped packages](https://docs.npmjs.com/misc/scope) so I can publish my generator without fear of name collisions.

Inside my generator package.json:
```
{
    ...
    "name": "@lohsy84/generator-node-express-application",
    ...   
}
```

To publish it to npm, I run the following command.

```bash
npm publish
```


Finally, I can invoke the published generator with the following command:

```bash
npm install @lohsy84/generator-node-express-application
yo @lohsy84/generator-node-express-application
```
