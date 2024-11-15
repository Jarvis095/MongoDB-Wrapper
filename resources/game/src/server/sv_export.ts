import { WithId } from "mongodb";
import { MongoDBdriver } from "./classes/driver";

const formatResult = (result: WithId<Document> | null | any) => {
    if (!result) return null;
    const { _id, ...rest } = result;
    return { ...rest, id: _id?.toString() };
};

setImmediate(async () => {
    global.exports('findOne', async (collection: string, query?: object, cb?: Function) => {
        try {
            const result = await MongoDBdriver.findOne(collection, query);
            const formattedResult = formatResult(result);
            cb?.(formattedResult);
            return formattedResult;
        } catch (error) {
            console.error("Error in findOne:", error);
            return error;
        }
    });

    global.exports('findAndReturnSpecificFields', async (collection: string, query?: object, fields?: object, cb?: Function) => {
        try {
            const result = await MongoDBdriver.findAndReturnSpecificFields(collection, query, fields);
            const formattedResult = formatResult(result);
            cb?.(formattedResult);
            return formattedResult;
        } catch (error) {
            console.error("Error in findAndReturnSpecificFields:", error);
            return error;
        }
    });

    global.exports('findMany', async (collection: string, query?: object, cb?: Function) => {
        try {
            const results = await MongoDBdriver.findMany(collection, query);
            const formattedResults = results.map(formatResult);
            cb?.(formattedResults);
            return formattedResults;
        } catch (error) {
            console.error("Error in findMany:", error);
            return error;
        }
    });

    global.exports('insertOne', async (collection: string, data: object, cb?: Function) => {
        console.log(collection, data);
        try {
            const result = await MongoDBdriver.insertOne(collection, data);
            const insertedIdString = result.insertedId.toString();
            cb?.(insertedIdString);
            return insertedIdString;
        } catch (error) {
            console.error("Error in insertOne:", error);
            return error;
        }
    });

    global.exports('insertMany', async (collection: string, data: object[], cb?: Function) => {
        try {
            const result = await MongoDBdriver.insertMany(collection, data);
            const insertedIdsStrings = Object.values(result.insertedIds).map(id => id.toString());
            cb?.(insertedIdsStrings);
            return insertedIdsStrings;
        } catch (error) {
            console.error("Error in insertMany:", error);
            return error;
        }
    });

    global.exports('updateOne', async (collection: string, query: object, newData: object, cb?: Function) => {
        console.log("updateOne", collection, query, newData);
        try {
            const result = await MongoDBdriver.updateOne(collection, query, newData);
            cb?.(result);
            return result;
        } catch (error) {
            console.error("Error in updateOne:", error);
            return error;
        }
    });

    global.exports('updateMany', async (collection: string, query: object, newData: object, cb?: Function) => {
        try {
            const result = await MongoDBdriver.updateMany(collection, query, newData);
            cb?.(result);
            return result;
        } catch (error) {
            console.error("Error in updateMany:", error);
            return error;
        }
    });

    global.exports('deleteOne', async (collection: string, query: object, cb?: Function) => {
        try {
            const result = await MongoDBdriver.deleteOne(collection, query);
            cb?.(result);
            return result;
        } catch (error) {
            console.error("Error in deleteOne:", error);
            return error;
        }
    });

    global.exports('deleteMany', async (collection: string, query: object, cb?: Function) => {
        try {
            const result = await MongoDBdriver.deleteMany(collection, query);
            cb?.(result);
            return result;
        } catch (error) {
            console.error("Error in deleteMany:", error);
            return error;
        }
    });
});
