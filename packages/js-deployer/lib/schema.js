const Joi = require('joi')

module.exports = Joi.object().keys({
    network: Joi.string().required(),
    name: Joi.string().required(),
    coreIp: Joi.string().required(),
    p2pPort: Joi.number().required(),
    apiPort: Joi.number().required(),
    dbHost: Joi.string().required(),
    dbPort: Joi.number().required(),
    dbUsername: Joi.string().required(),
    dbPassword: Joi.string().required(),
    dbDatabase: Joi.string().required(),
    explorerUrl: Joi.string()
        .uri({ scheme: ["http", "https"] })
        .required(),
    forgers: Joi.number().required(),
    epoch: Joi.string()
        .regex(
            /\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z)/
        )
        .required(),
    rewardHeight: Joi.number()
        .integer()
        .positive()
        .required(),
    rewardPerBlock: Joi.number().required(),
    vendorFieldLength: Joi.number().required(),
    blocktime: Joi.number().required(),
    token: Joi.string().required(),
    symbol: Joi.string().required(),
    peers: Joi.string().allow(""),
    prefixHash: Joi.number().required(),
    transactionsPerBlock: Joi.number().required(),
    wifPrefix: Joi.number()
        .integer()
        .min(1)
        .max(255)
        .required(),
    totalPremine: Joi.string().required(),
    configPath: Joi.string().required(),
    // Static Fees
    feeStaticTransfer: Joi.number().required(),
    feeStaticVote: Joi.number().required(),
    feeStaticSecondSignature: Joi.number().required(),
    feeStaticDelegateRegistration: Joi.number().required(),
    feeStaticMultiSignature: Joi.number().required(),
    feeStaticIpfs: Joi.number().required(),
    feeStaticMultiPayment: Joi.number().required(),
    feeStaticDelegateResignation: Joi.number().required(),
    feeStaticHtlcLock: Joi.number().required(),
    feeStaticHtlcClaim: Joi.number().required(),
    feeStaticHtlcRefund: Joi.number().required(),
    // Dynamic Fees
    feeDynamicEnabled: Joi.boolean().required(),
    feeDynamicPoolMinFee: Joi.number().required(),
    feeDynamicBroadcastMinFee: Joi.number().required(),
    feeDynamicBytesTransfer: Joi.number().required(),
    feeDynamicBytesSecondSignature: Joi.number().required(),
    feeDynamicBytesDelegateRegistration: Joi.number().required(),
    feeDynamicBytesVote: Joi.number().required(),
    feeDynamicBytesMultiSignature: Joi.number().required(),
    feeDynamicBytesIpfs: Joi.number().required(),
    feeDynamicBytesHtlcLock: Joi.number().required(),
    feeDynamicBytesHtlcClaim: Joi.number().required(),
    feeDynamicBytesHtlcRefund: Joi.number().required(),
    feeDynamicBytesMultiPayment: Joi.number().required(),
    feeDynamicBytesDelegateResignation: Joi.number().required(),
    feeDynamicBytesBusinessRegistration: Joi.number().required(),
    feeDynamicBytesBusinessUpdate: Joi.number().required(),
    feeDynamicBytesBusinessResignation: Joi.number().required(),
    feeDynamicBytesBridgechainRegistration: Joi.number().required(),
    feeDynamicBytesBridgechainUpdate: Joi.number().required(),
    feeDynamicBytesBridgechainResignation: Joi.number().required()
});
