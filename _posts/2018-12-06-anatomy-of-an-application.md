---
layout: post
title:  "Anatomy of a Web Application"
author: samuel
categories: [ application-development ]
image: https://images.unsplash.com/photo-1479839672679-a46483c0e7c8?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2754&q=80
featured: false
hidden: false
---

When writing my web applications, I follow a number of standards that I learnt during my software engineering Bachelor's degree and my career. While the programming language I use differs from project to project, I always end up with the same project layout and coding style. My colleagues generally identify my code as Java-like, regardless of whether it's written in PHP, Node.JS or Python.

Here is an ASCII tree that shows my typical project structure for an application.
```
project_dir
├── bin/
├── routes/
├── dao/
├── util/
├── services/
├── model/
├── static/
│   ├── css/
│   ├── images/
│   ├── js/
│   └── fonts/
├── views/
├── docs/
├── tests/
├── Makefile
├── TODO.md
└── README.md
```

### Presentation, Domain, Data Tiers

The most basic characteristic of my web applications is the separation of my application logic into the Presentation,  and Data layers. I've bought the [Patterns of Enterprise Application Architecture](https://martinfowler.com/books/eaa.html) textbook from Martin Fowler, but this was actually taught to me by a fellow project member in my 3rd year Software Engineering project. I've never strayed from this rule since. More details on this are on [Martin Fowler's post on PresentationDomainDataLayering](https://martinfowler.com/bliki/PresentationDomainDataLayering.html).  

The idea is to separate your application logic into neat tiers. While your application logic can go into any of the tiers, it is better to organize them according to your own coding habits. This makes maintenance of the application easier, and wiring up of functionality much neater.

The Model-View-Controller pattern is a concrete example of the Presentation, Domain and Data Tiering. 
* You define data Models, as data structures with associated functions to be passed around between Presentation, Domain and Data tiers.
* Starting from the View Tier, end-users are presented with a user interface to request for data from the Controllers.
* The Controller in the Domain Tier receives the request from the View and initiates a request for data from the Data Tier. 
* The Data tier retrieves data from the database and instantiates the data Models, passing them to the Controller. 
* The Controller in the Domain tier applies business logic to the data Models and passes them to a View for rendering.
* The View renders the requested data and presents user interface controls to perform operations on the data.

For me, this means the following process:
1. Define data models for each domain object in the ```model/``` directory. 
   Usually these are class definitions with metadata describing the type of each attribute of the class and possibly some instance methods. This is heavily dependent on the object relational mapping (ORM)/object document mapper (ODM) library I'm using.
     
2. Define data access objects for each domain object in the ```dao/``` directory. For each domain object, define the usual list, create, read, update and delete (CRUD) methods, and any convenience methods for executing special database queries like joins and aggregations. This couples tightly with the ORM/ODM library of choice. While this layer can be quite trivial to write, it's important to keep in the event of a ORM/ODM library upgrade or change. 

3. Define services for each domain object in the ```services/``` directory. For each domain object, define a service that exposes the list and CRUD methods in the corresponding data access object. Any additional logic for working with the domain object goes into the service for that domain object.

4. Define controllers for each domain object in the ```routes/``` directory. Whether I'm building a single page application (SPA) or not, I try to follow the RESTful API standard when defining routes for each domain object. I'll cover more on RESTful API standards in another article.

5. Define views for each domain object in the ```views``` directory. If I'm writing a quick and dirty application, I use a view rendering engine to render my HTML templates. I'll cover my usual user interface development process in another article.

Other common aspects of my projects is that I love writing Singleton or Static utility classes, partially because it's how I learn to work with new frameworks or libraries. Transcribing complicated operations that combine one or more libraries into simple functions defined by yourself is a great way to build up your repertoire of enterprisey application functions. Eventually you will develop a collection of trusted libraries and frameworks and you will have code snippets that ease the use of these libraries that are common among all your projects. For me, the Singleton Utility classes (classes that need instantiation) go into the ```services/``` directory and the Static Utility classes go into the ```util/``` directory.
   
One of the things I have to improve upon is my documentation. The above work process is well defined enough to explain what's going on in each project (self-documenting code), but other things that can't be captured in code, like design considerations and decisions should go into Markdown or plaintext readme files in the project root or the ```docs/``` directory.

I also like to write alot of Bash scripts, Dockerfiles and Docker Compose files to perform common tasks. Like installing required libraries, or running databases in Docker containers. These also go into the project root directory. The important ones go into the ```bin/``` directory. 

Occasionally, when the application needs to be of a certain quality, I will write test cases for it in the ```tests/``` directory. The testing directory structure closely resembles the project directory structure and contains all the unit test cases to test each component. 

