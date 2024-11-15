import { MongoClient, Db, ObjectId, MongoClientOptions } from 'mongodb';
import now from 'performance-now';

if (typeof performance === 'undefined') {
    //@ts-ignore
    global.performance = { now };
}

class Driver {
    private client: MongoClient;
    public dbName: string = GetConvar("mongodbDatabase", "none");
    private url: string = GetConvar("mongodbURL", "none");
    private poolSize: number = GetConvarInt("mongodbPoolSize", 20);
    public connected: boolean = false;
    private db: Db;

    constructor() {
        if (this.url === 'none' || this.dbName === 'none') {
            throw new Error('Both `url` and `dbName` must be provided and cannot be "none".');
        }
        this.client = new MongoClient(this.url, {
            maxPoolSize: this.poolSize, // adjust this based on expected concurrency
        } as MongoClientOptions);
        this.db = this.client.db(this.dbName);
    }

    public async connect() {
        if (!this.connected) {
            await this.client.connect();
            this.connected = await this.doesDBexist();
        }
    }

    private async doesDBexist(): Promise<boolean> {
        const admin = this.client.db().admin();
        const dbInfo = await admin.listDatabases();
        const isDbExist = dbInfo.databases.some((db) => db.name === this.dbName);

        if (isDbExist) {
            console.log(`\x1b[36m[MongoDB]\x1b[0m Connected to database "${this.dbName}".`);
        } else {
            await this.db.createCollection("test");
            console.log(`\x1b[36m[MongoDB]\x1b[0m Created database "${this.dbName}".`);
        }
        return isDbExist;
    }

    private collection(name: string) {
        return this.db.collection(name);
    }

    private convertId(query: any): any {
        if (query._id && typeof query._id === "string") {
            query._id = new ObjectId(query._id);
        }
        return query;
    }

    public async findOne(collection: string, query: object) {
        return await this.collection(collection).findOne(this.convertId(query));
    }

    public async findAndReturnSpecificFields(collection: string, query: object, fields: object) {
        return await this.collection(collection).findOne(this.convertId(query), { projection: fields });
    }

    public async findMany(collection: string, query: object) {
        return await this.collection(collection).find(this.convertId(query)).toArray();
    }

    public async insertOne(collection: string, data: object) {
        return await this.collection(collection).insertOne(data);
    }

    public async insertMany(collection: string, data: object[]) {
        return await this.collection(collection).insertMany(data);
    }

    public async updateOne(collection: string, query: object, newData: object) {
        return await this.collection(collection).updateOne(this.convertId(query), { $set: newData });
    }

    public async updateMany(collection: string, query: object, newData: object) {
        return await this.collection(collection).updateMany(this.convertId(query), { $set: newData });
    }

    public async deleteOne(collection: string, query: object) {
        return await this.collection(collection).deleteOne(this.convertId(query));
    }

    public async deleteMany(collection: string, query: object) {
        return await this.collection(collection).deleteMany(this.convertId(query));
    }
}

export const MongoDBdriver = new Driver();