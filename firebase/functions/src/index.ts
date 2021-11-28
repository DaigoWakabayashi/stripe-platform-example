import * as functions from 'firebase-functions';
import * as firebaseAdmin from 'firebase-admin';
import * as stripe from './stripe';

// Firebaseプロジェクトの初期化
firebaseAdmin.initializeApp(functions.config().firebase);

export {
    stripe,
};