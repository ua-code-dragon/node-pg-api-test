
const Pool = require('pg').Pool
const pool = new Pool({
    user:       process.env.PGUSER,
    host:       process.env.PGHOST,
    database:   process.env.PGDB,
    password:   process.env.PGPASSWORD,
    port:       process.env.PGPORT
});

async function get_user_auth (user, pass)  {
    try{
        const {rows} = await pool.query("select * from api_user_auth($1);",[{username: user, password: pass}]);
        if(rows.length > 0){
            if(rows[0].errcode == 0){
                return rows[0].result;
            }else{
                throw rows[0].errmsg;
            }
        }
        return null;
    } catch (err) {
        throw err;
    }        
}

async function get_user_data ( req ) { 
    try{
        const {rows} = await pool.query("select * from api_user_data($1);",[req]);
        if(rows.length > 0){
            if(rows[0].errcode == 0){
                return rows[0].result;
            }else{
                throw rows[0].errmsg;
            }
        }
        return null;
    } catch (err) {
        throw err;
    }        

}

async function add_data() {
    await pool.query("insert into userdata ( username, x, y, z ) select username, random() * 100, random() * 100, random() * 100 from users;");    
}


module.exports = {
    get_user_auth,
    get_user_data,
    add_data
};

