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
    const feeAmount = Math.floor(amount * 1 / 10); // 10%の手数料を引いた値を小数点以下で切り捨てる
    const targetAccountId = data.targetAccountId; // 送金先のアカウント

    // 決済を作成
    const charge = await stripe.charges.create({
        customer: customer,
        amount: amount,
        currency: "jpy",
        application_fee_amount: feeAmount,
        transfer_data: {
            destination: targetAccountId,
        },
    }, {
        idempotencyKey: data.idempotencyKey,
    },);
    console.log('charges %j', charge);
    return {chargeId: charge.id};
});


///
/// Connect Account（お金を受け取る側）
///


// MARK: - ConnectAccountを作成し、accountIdを返す
export const createConnectAccount = functions.region("asia-northeast1").https.onCall(async (data, context) => {
    return await stripe.accounts.create({
        type: 'custom', // 必須
        country: 'JP',
        email: data.email,
        business_type: 'individual',
        business_profile: {
                mcc: '5734', // 業種コード（5834 → Computer Software Stores）
                url: 'https://github.com/DaigoWakabayashi/stripe-platform-example', // 事業のウェブサイト
                product_description: 'プラットフォーム型サービスのテストアカウントです', // 事業の内容
            },
        capabilities: {
            card_payments: { requested: true }, // カード決済
            transfers: { requested: true }, // 送金
        },
        individual: {
            email: data.email,
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
            individual: data.individual, // 本人確認情報
            tos_acceptance: data.tos_acceptance, // 利用規約への同意
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


// Firestore の user ステータスを変更する
const _updateUserStatus = async (account: any) => {
    const db = firebaseAdmin.firestore();
    const accountData = account;
    /// accountId から該当の user を取得
    const snap = await db.collection('users').where('accountId', '==', accountData.id).get();
    const userDoc = snap.docs[0];
    // 現在のステータスを取得
    const currentStatus = userDoc.data()['status'];
    console.log('現在のstatus:', currentStatus);
    let stripeStatus = currentStatus;
    // 次のステータスを代入
    stripeStatus = accountData.individual.verification.status; // stripeのstatus（ unverified, pending, verified )
    const chargesEnabled = accountData.charges_enabled; // 被決済の可否

    /// Firestoreのstatusを変更
    console.log('次のstatus:', stripeStatus);
    await userDoc.ref.update({
        'status': stripeStatus,
        'chargesEnabled': chargesEnabled,
    });
}

// MARK: Connect Account の update をトリガーに、Firestoreのstatusを変更する（Stripeから呼ばれる関数）
export const updateStripeAccountStatus = functions.region("asia-northeast1").https.onRequest(async (req, res) => {
    const event = req.body;
    console.log('event %j', event);
    const account = event.data.object;
    console.log('account %j', account);

    try {
        // event 内の account オブジェクトから status を判断する
        await _updateUserStatus(account);
        res.status(200).json({ received: true });
    } catch (error) {
        console.log('エラー', error);
        res.status(400).json({ received: false });
    }
});