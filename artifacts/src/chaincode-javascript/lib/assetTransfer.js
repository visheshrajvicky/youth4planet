/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class AssetTransfer extends Contract {

    async InitLedger(ctx) {
        const assets = [
            {
                VideoID: "V001",
                VideoTitle:"Mirjapur",
                VideoOwner:"Amazone Prime Video",
                IpfsHash:"haskhfkfhsljfhlsdfjhy7384rbfhf4f7v9dfvkdjvbslvflsb",
                Date: "23-04-2019 3:00 PM",
            },
            {
                VideoID: "V002",
                VideoTitle: "Sacred Game",
                VideoOwner: "Netflix",
                IpfsHash: "fhdi34jf8ffbfu8rej48jf840fbp44fhieroer754bfisvbxmie",
                Date: "02-04-2019 5:00 AM",
            },
            {
                VideoID: "V003",
                VideoTitle: "Iron Mam",
                VideoOwner: "Marvel",
                IpfsHash: "fjkhffh748jdkhhf83cbkvchkvyfuvbcvkhre78340482bkczb",
                Date: "03-04-2020 12:00 PM",
            },
            {
                VideoID: "V004",
                VideoTitle: "Avengers",
                VideoOwner: "Marvel2",
                IpfsHash: "fdlueiesmc4nmci843kiufueoc993k4kblacbv943ka943a4kjfal84",
                Date: "23-05-2020 7:00 PM",
            },
            {
                VideoID: "V005",
                VideoTitle: "Tiger Jinda Hai",
                VideoOwner: "Salman Khan Films",
                IpfsHash: "d4894bjkfue5945hjakbfhfryue55jwvbxmse843jhs3057",
                Date: "05-04-2018 8:00 PM",
            },
            {
                VideoID: "V006",
                VideoTitle: "Big Boss",
                VideoOwner: "Salemon Bhoi",
                IpfsHash: "a459fsdbfue55hjakbfhfryue55jwvbxmse843jhs3057",
                Date: "23-04-20201 3:00 PM",
            },
        ];

        for (const asset of assets) {
            asset.docType = 'asset';
            await ctx.stub.putState(asset.VideoID, Buffer.from(JSON.stringify(asset)));
            console.info(`Asset ${asset.VideoID} initialized`);
        }
    }

    // CreateAsset issues a new asset to the world state with given details.
    async CreateAsset(ctx, videoID, videoTitle, videoOwner, ipfsHash, uploadDate) {
        const asset = {
            VideoID: videoID,
            VideoTitle: videoTitle,
            VideoOwner: videoOwner,
            IpfsHash: ipfsHash,
            Date: uploadDate,
        };
        await ctx.stub.putState(videoID, Buffer.from(JSON.stringify(asset)));
        return JSON.stringify(asset);
    }

    // ReadAsset returns the asset stored in the world state with given id.
    async ReadAsset(ctx, videoID) {
        const assetJSON = await ctx.stub.getState(videoID); // get the asset from chaincode state
        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`The asset ${videoID} does not exist`);
        }
        return assetJSON.toString();
    }

    // UpdateAsset updates an existing asset in the world state with provided parameters.
    async UpdateAsset(ctx, videoID, videoTitle, videoOwner, ipfsHash, uploadDate) {
        const exists = await this.AssetExists(ctx, videoID);
        if (!exists) {
            throw new Error(`The asset ${videoID} does not exist`);
        }

        // overwriting original asset with new asset
        const updatedAsset = {
            VideoID: videoID,
            VideoTitle: videoTitle,
            VideoOwner: videoOwner,
            IpfsHash: ipfsHash,
            Date: uploadDate,
        };
        return ctx.stub.putState(videoID, Buffer.from(JSON.stringify(updatedAsset)));
    }

    // DeleteAsset deletes an given asset from the world state.
    async DeleteAsset(ctx, videoID) {
        const exists = await this.AssetExists(ctx, videoID);
        if (!exists) {
            throw new Error(`The asset ${videoID} does not exist`);
        }
        return ctx.stub.deleteState(videoID);
    }

    // AssetExists returns true when asset with given ID exists in world state.
    async AssetExists(ctx, videoID) {
        const assetJSON = await ctx.stub.getState(videoID);
        return assetJSON && assetJSON.length > 0;
    }

    // TransferAsset updates the owner field of asset with given id in the world state.
    // async TransferAsset(ctx, id, newOwner) {
    //     const assetString = await this.ReadAsset(ctx, id);
    //     const asset = JSON.parse(assetString);
    //     asset.Owner = newOwner;
    //     return ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
    // }

    // GetAllAssets returns all assets found in the world state.
    async GetAllAssets(ctx) {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: result.value.key, Record: record });
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }
}

module.exports = AssetTransfer;
