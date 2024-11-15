import { MongoDBdriver } from "./classes/driver"

setImmediate(async () => {
    await MongoDBdriver.connect().then(async (res) => {
        emit("mongoDB:server:connected")
    }).catch((error) => {
        console.log(`\x1b[36m[MongoDB]\x1b[31m[ERROR]\x1b[0m Failed connecting to database.`)
        console.log(error)
    })
});