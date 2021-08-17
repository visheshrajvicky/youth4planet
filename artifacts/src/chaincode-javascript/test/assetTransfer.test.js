/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
*/

'use strict';
const sinon = require('sinon');
const chai = require('chai');
const sinonChai = require('sinon-chai');
const expect = chai.expect;

const { Context } = require('fabric-contract-api');
const { ChaincodeStub } = require('fabric-shim');

const AssetTransfer = require('../lib/assetTransfer.js');

let assert = sinon.assert;
chai.use(sinonChai);

describe('Asset Transfer Basic Tests', () => {
    let transactionContext, chaincodeStub, asset;
    beforeEach(() => {
        transactionContext = new Context();

        chaincodeStub = sinon.createStubInstance(ChaincodeStub);
        transactionContext.setChaincodeStub(chaincodeStub);

        chaincodeStub.putState.callsFake((key, value) => {
            if (!chaincodeStub.states) {
                chaincodeStub.states = {};
            }
            chaincodeStub.states[key] = value;
        });

        chaincodeStub.getState.callsFake(async (key) => {
            let ret;
            if (chaincodeStub.states) {
                ret = chaincodeStub.states[key];
            }
            return Promise.resolve(ret);
        });

        chaincodeStub.deleteState.callsFake(async (key) => {
            if (chaincodeStub.states) {
                delete chaincodeStub.states[key];
            }
            return Promise.resolve(key);
        });

        chaincodeStub.getStateByRange.callsFake(async () => {
            function* internalGetStateByRange() {
                if (chaincodeStub.states) {
                    // Shallow copy
                    const copied = Object.assign({}, chaincodeStub.states);

                    for (let key in copied) {
                        yield {value: copied[key]};
                    }
                }
            }

            return Promise.resolve(internalGetStateByRange());
        });

        asset = {
            VideoID: "V001",
            VideoTitle:"Mirjapur",
            VideoOwner:"Amazone Prime Video",
            IpfsHash:"haskhfkfhsljfhlsdfjhy7384rbfhf4f7v9dfvkdjvbslvflsb",
            Date: "23-04-2019 3:00 PM",
        };
    });

    describe('Test InitLedger', () => {
        it('should return error on InitLedger', async () => {
            chaincodeStub.putState.rejects('failed inserting key');
            let assetTransfer = new AssetTransfer();
            try {
                await assetTransfer.InitLedger(transactionContext);
                assert.fail('InitLedger should have failed');
            } catch (err) {
                expect(err.name).to.equal('failed inserting key');
            }
        });

        it('should return success on InitLedger', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.InitLedger(transactionContext);
            let ret = JSON.parse((await chaincodeStub.getState('V001')).toString());
            expect(ret).to.eql(Object.assign({docType: 'asset'}, asset));
        });
    });

    describe('Test CreateAsset', () => {
        it('should return error on CreateAsset', async () => {
            chaincodeStub.putState.rejects('failed inserting key');

            let assetTransfer = new AssetTransfer();
            try {
                await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);
                assert.fail('CreateAsset should have failed');
            } catch(err) {
                expect(err.name).to.equal('failed inserting key');
            }
        });

        it('should return success on CreateAsset', async () => {
            let assetTransfer = new AssetTransfer();

            await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);

            let ret = JSON.parse((await chaincodeStub.getState(asset.VideoID)).toString());
            expect(ret).to.eql(asset);
        });
    });

    describe('Test ReadAsset', () => {
        it('should return error on ReadAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);

            try {
                await assetTransfer.ReadAsset(transactionContext, 'asset2');
                assert.fail('ReadAsset should have failed');
            } catch (err) {
                expect(err.message).to.equal('The asset asset2 does not exist');
            }
        });

        it('should return success on ReadAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);

            let ret = JSON.parse(await chaincodeStub.getState(asset.VideoID));
            expect(ret).to.eql(asset);
        });
    });

    describe('Test UpdateAsset', () => {
        it('should return error on UpdateAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);

            try {
                await assetTransfer.UpdateAsset(transactionContext, 'V007', 'Mickey Mouse', 'Disney', 'dlkfh5495jklnjfds89fs4lkjfb94589fsjfbslb5849', '20-06-2021' );
                assert.fail('UpdateAsset should have failed');
            } catch (err) {
                expect(err.message).to.equal('The asset asset2 does not exist');
            }
        });

        it('should return success on UpdateAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);

            await assetTransfer.UpdateAsset(transactionContext, 'V007', 'Mickey Mouse', 'Disney', 'dlkfh5495jklnjfds89fs4lkjfb94589fsjfbslb5849', '20-06-2021');
            let ret = JSON.parse(await chaincodeStub.getState(asset.VideoID));
            let expected = {
                VideoID: "V001",
                VideoTitle:"Mirjapur",
                VideoOwner:"Amazone Prime Video",
                IpfsHash:"haskhfkfhsljfhlsdfjhy7384rbfhf4f7v9dfvkdjvbslvflsb",
                Date: "23-04-2019 3:00 PM",
            };
            expect(ret).to.eql(expected);
        });
    });

    describe('Test DeleteAsset', () => {
        it('should return error on DeleteAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);

            try {
                await assetTransfer.DeleteAsset(transactionContext, 'V002');
                assert.fail('DeleteAsset should have failed');
            } catch (err) {
                expect(err.message).to.equal('The asset asset2 does not exist');
            }
        });

        it('should return success on DeleteAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);

            await assetTransfer.DeleteAsset(transactionContext, asset.VideoID);
            let ret = await chaincodeStub.getState(asset.VideoID);
            expect(ret).to.equal(undefined);
        });
    });

    describe('Test TransferAsset', () => {
        it('should return error on TransferAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);

            try {
                await assetTransfer.TransferAsset(transactionContext, 'asset2', 'Me');
                assert.fail('DeleteAsset should have failed');
            } catch (err) {
                expect(err.message).to.equal('The asset asset2 does not exist');
            }
        });

        it('should return success on TransferAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.VideoID, asset.VideoTitle, asset.VideoOwner, asset.IpfsHash, asset.Date);

            await assetTransfer.TransferAsset(transactionContext, asset.VideoID, 'Me');
            let ret = JSON.parse((await chaincodeStub.getState(asset.VideoID)).toString());
            expect(ret).to.eql(Object.assign({}, asset, {VideoOwner: 'Me'}));
        });
    });

    describe('Test GetAllAssets', () => {
        it('should return success on GetAllAssets', async () => {
            let assetTransfer = new AssetTransfer();

            await assetTransfer.CreateAsset(transactionContext, 'V001', 'Mirzapur', 'Amazon Prime Video', 'chjbdlvhfbvshfbslhdfbljshvblfsvhbsb', '5-05-2010');
            await assetTransfer.CreateAsset(transactionContext, 'V002', 'Sacred Game', 'Netflix', 'Paul', '23-02-2020 ');
            await assetTransfer.CreateAsset(transactionContext, 'V003', 'Iron Mam', 'Marvel', 'jlhsbhsbvlsvhjbvhj', '04-01-2021');
            await assetTransfer.CreateAsset(transactionContext, 'V004', 'Avenger', 'Marvel', 'fjlsdnjfnsljfjsnvjflsnv', '28-03-2021');

            let ret = await assetTransfer.GetAllAssets(transactionContext);
            ret = JSON.parse(ret);
            expect(ret.length).to.equal(4);

            let expected = [
                {Record: {VideoID: 'V001', VideoTitle: 'Mirzapur',  VideoOwner: 'Robert',IpfsHash:"jfsk", Date: '100'}},
                {Record: {VideoID: 'V002', VideoTitle: 'Sacred Game', VideoOwner: '10', IpfsHash: 'Paul', Date: '200'}},
                {Record: {VideoID: 'V003', VideoTitle: 'Iron Mam', VideoOwner: '15', IpfsHash: 'Troy', Date: '300'}},
                {Record: {VideoID: 'V004', VideoTitle: 'Avenger', VideoOwner: '20', IpfsHash: 'Van', Date: '400'}}
            ];

            expect(ret).to.eql(expected);
        });

        it('should return success on GetAllAssets for non JSON value', async () => {
            let assetTransfer = new AssetTransfer();

            chaincodeStub.putState.onFirstCall().callsFake((key, value) => {
                if (!chaincodeStub.states) {
                    chaincodeStub.states = {};
                }
                chaincodeStub.states[key] = 'non-json-value';
            });

            await assetTransfer.CreateAsset(transactionContext, 'V001', 'Mirzapur', 'Amazon Prime Video', 'chjbdlvhfbvshfbslhdfbljshvblfsvhbsb', '5-05-2010');
            await assetTransfer.CreateAsset(transactionContext, 'V002', 'Sacred Game', 'Netflix', 'Paul', '23-02-2020 ');
            await assetTransfer.CreateAsset(transactionContext, 'V003', 'Iron Mam', 'Marvel', 'jlhsbhsbvlsvhjbvhj', '04-01-2021');
            await assetTransfer.CreateAsset(transactionContext, 'V004', 'Avenger', 'Marvel', 'fjlsdnjfnsljfjsnvjflsnv', '28-03-2021');

            let ret = await assetTransfer.GetAllAssets(transactionContext);
            ret = JSON.parse(ret);
            expect(ret.length).to.equal(4);

            let expected = [
                {Record: {VideoID: 'V001', VideoTitle: 'Mirzapur',  VideoOwner: 'Robert',IpfsHash:"jfsk", Date: '100'}},
                {Record: {VideoID: 'V002', VideoTitle: 'Sacred Game', VideoOwner: '10', IpfsHash: 'Paul', Date: '200'}},
                {Record: {VideoID: 'V003', VideoTitle: 'Iron Mam', VideoOwner: '15', IpfsHash: 'Troy', Date: '300'}},
                {Record: {VideoID: 'V004', VideoTitle: 'Avenger', VideoOwner: '20', IpfsHash: 'Van', Date: '400'}}
            ];

            expect(ret).to.eql(expected);
        });
   });
});
