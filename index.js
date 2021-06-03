const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const jwt = require('jsonwebtoken');
const cookieParser = require('cookie-parser');
const cron = require('node-cron');
const db = require('./model')
const app = express();
const port = 3000
const accessTokenSecret = 'bmFtZSI6ImFkbWluIiwicm9sZXMiOm51bGwsImlhdCI6MTYyMjY3NjM2M';

app.use(bodyParser.json());
app.use(
    bodyParser.urlencoded({
        extended: true
    })
);
app.use(cookieParser());

app.set("views", path.join(__dirname, "views"));
app.set("view engine", "pug");
app.use('/static', express.static(__dirname + '/static'));

cron.schedule('*/2 * * * * *', async () => {
    await db.add_data();
    console.log("CRON: add data");
});

const authJWT = async (req, res, next) => {
    let token;
    if(req.cookies){
        token = req.cookies.jwt;
    }    
    if (token ) {
        jwt.verify(token, accessTokenSecret, (err, user) => {
            if (err) {
                return res.sendStatus(403);
            }
            req.user = user;
            next();
        });
    }else{
        res.status(401).redirect('/ntest/login');
    }
};        

app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;
    const dbres = await db.get_user_auth(username, password);
    if(dbres){
        const user = dbres[0];
        const accessToken = await jwt.sign(user, accessTokenSecret);
        res.cookie('jwt', accessToken, {
            maxAge: 3 * 24 * 60 * 60,
            httpOnly: false
        });
        res.status(200).send();

    }else{
        req.app.set('msg','Username or password incorrect');
        res.status(401).redirect('/ntest/login');
    }
});

app.post('/api/logout', authJWT, async (req, res) => {
    res.clearCookie('jwt');
    res.redirect('/ntest');
});

app.post('/api/data', authJWT, async (req, res) => {
    const { after, limit } = req.body;
    const dbres = await db.get_user_data({ username: req.user.username, after: after, limit: limit });
    if(dbres){
        res.json(dbres);
    }else{
        res.json([]);
    }
});

app.get('/login', (req, res) => {
    res.render("login", { title: "Login", msg: req.app.get('msg') });
}); 

app.get('/', authJWT, (req, res) => {
    const user = req.user;
    res.render("index", { title: "Home", user: user });
});

app.listen(port, () => {
    console.log(`App running on port ${port}.`);
});


