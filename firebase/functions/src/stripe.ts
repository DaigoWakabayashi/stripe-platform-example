import * as functions from 'firebase-functions';
import * as firebaseAdmin from 'firebase-admin';

// Stripe の SecretKey（sk_〇〇〇〇） を環境変数に保存
const stripe = require('stripe')(functions.config().secret.stripe.secret_key,  {
    typescript: true,
  });


/// 
/// Customer（お金を払うアカウント）
///


// MARK: - stripeのcustomerを作ってcustomerIdを返す
export const createCustomer = functions.region("asia-northeast1").https.onCall(async (data, context) => {
    const email = data.email;
    const customer = await stripe.customers.create(
        { email: email },
        { idempotencyKey: data.idempotencyKey });
    const customerId = customer.id;
    return { customerId: customerId }
});

// MARK: カード情報の登録
export const createCardInfo = functions.region("asia-northeast1").https.onCall((data, context) => {
    const customerId = data.customerId;
    const cardToken = data.cardToken;
    return stripe.customers.createSource(
        customerId,
        { source: cardToken },
    );
});

// MARK: - カード情報の取得
export const retrieveCardInfo = functions.region("asia-northeast1").https.onCall((data, context) => {
    const customerId = data.customerId;
    const cardId = data.cardId;
    return stripe.customers.retrieveSource(
        customerId,
        cardId
    );
});

// MARK: カード情報の削除
export const deleteCardInfo = functions.region("asia-northeast1").https.onCall((data, context) => {
    const customerId = data.customerId;
    const cardId = data.cardId;
    return stripe.customers.deleteSource(
        customerId,
        cardId,
    );
});


///
/// Charges（単発決済）
///

// MARK: - 決済を作成する
export const createStripeCharge = functions.region("asia-northeast1").https.onCall(async (data, context) => {
    const customer = data.customerId; // 顧客
    const amount = data.amount; // 支払い総額

    // 決済を作成
    const charge = await stripe.charges.create({
        customer: customer,
        amount: amount,
        // todo : 手数料を取る
        currency: "jpy",
    }, {
        idempotencyKey: data.idempotencyKey,
    },);
    
    return {chargeId: charge.id};
});


///
/// Connect Account（お金を受け取る側）
///


// MARK: - ConnectAccountを作成し、accountIdを返す
export const createConnectAccount = functions.region("asia-northeast1").https.onCall(async (data, context) => {
    return await stripe.accounts.create({
        type: 'custom',
        country: 'JP',
        email: data.email,
        business_type: 'individual',
        capabilities: {
            card_payments: { requested: true },
            transfers: { requested: true },
        },
        settings: {
            payouts: {
                schedule: {
                    interval: 'manual',
                },
            },
        },
    }, {
        idempotencyKey: data.idempotencyKey,
    });
});

// MARK: - ConnectAccountを更新し、結果を返す
export const updateConnectAccount = functions.region("asia-northeast1").https.onCall(async (data, context) => {
    const result = await stripe.accounts.update(
        data.accountId,
        {
            individual: data.individual,
            tos_acceptance: data.tos_acceptance,
        },
        { idempotencyKey: data.idempotencyKey }
    );
    return result;
});

// MARK: - ConnectAccountを取得し、結果を返す
export const retrieveConnectAccount = functions.region("asia-northeast1").https.onCall((data, context) => {
    return stripe.accounts.retrieve(
        data.accountId,
        { idempotencyKey: data.idempotencyKey }
    );
});


// Stripe の account オブジェクト からステータスを判断するロジック
const _updateNpoProjectStatus = async (account: any) => {
    const db = firebaseAdmin.firestore();
    const accountData = account;
    /// accountIdから該当のNPOを取得
    const snap = await db.collection('projects').where('stripeAccountId', '==', accountData.id).get();
    console.log(snap.docs);
}

// MARK: Connect Account の update をトリガーに、Firestoreのstatusを変更する（Stripeから呼ばれる関数）
export const updateStripeAccountStatus = functions.region("asia-northeast1").https.onRequest(async (req, res) => {
    const event = req.body;
    const account = event.data.object;
    try {
        // event 内の account オブジェクトから status を判断する
        await _updateNpoProjectStatus(account);
        res.status(200).json({ received: true });
    } catch (error) {
        console.log('エラー', error);
        res.status(400).json({ received: false });
    }
});