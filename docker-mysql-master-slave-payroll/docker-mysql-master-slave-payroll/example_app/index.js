import mysql from 'mysql';
import util from 'util';

const masterConnection = mysql.createConnection({
  host: "127.0.0.1",
  user: "mydb_user",
  password: "mydb_pwd",
  port: 4406,
  database: "mydb",
});

const slaveConnection = mysql.createConnection({
  host: "127.0.0.1",
  user: "mydb_slave_user",
  password: "mydb_slave_pwd",
  port: 5506,
  database: "mydb",
});

const slaveConnection2 = mysql.createConnection({
  host: "127.0.0.1",
  user: "mydb_slave_user2",
  password: "mydb_slave_pwd2",
  port: 6606,
  database: "mydb",
});

const slaveConnection3 = mysql.createConnection({
  host: "127.0.0.1",
  user: "mydb_slave_user3",
  password: "mydb_slave_pwd3",
  port: 7706,
  database: "mydb",
});

const slaveConnection4 = mysql.createConnection({
  host: "127.0.0.1",
  user: "mydb_slave_user4",
  password: "mydb_slave_pwd4",
  port: 8806,
  database: "mydb",
});

(async () => {
  const masterQuery = util.promisify(masterConnection.query).bind(masterConnection);
  const masterResults = await masterQuery("INSERT INTO code VALUES (?)", [3000]);
  console.log(masterResults);
  const masterCommit = util.promisify(masterConnection.commit).bind(masterConnection);
  await masterCommit();
  masterConnection.end();

  const slaveQuery = util.promisify(slaveConnection.query).bind(slaveConnection);
  const slaveResults = await slaveQuery("SELECT * FROM code");
  slaveConnection.end();

  console.log(slaveResults);
})()
